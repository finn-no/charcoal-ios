//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import UIKit

protocol RangeFilterViewDelegate: AnyObject {
    func rangeFilterView(_ rangeFilterView: RangeFilterView, didSetLowValue lowValue: Int?)
    func rangeFilterView(_ rangeFilterView: RangeFilterView, didSetHighValue highValue: Int?)
}

final class RangeFilterView: UIView {
    private enum InputValue {
        case low, high
    }

    weak var delegate: RangeFilterViewDelegate?

    private let filterConfig: RangeFilterConfiguration
    private let formatter: RangeFilterValueFormatter
    private var inputValues = [InputValue: Step]()
    private var referenceValueViews = [SliderReferenceValueView]()

    var generatesHapticFeedbackOnSliderValueChange = true {
        didSet {
            sliderInputView.generatesHapticFeedbackOnValueChange = generatesHapticFeedbackOnSliderValueChange
        }
    }

    private lazy var numberInputView: RangeNumberInputView = {
        let rangeNumberInputView = RangeNumberInputView(
            minimumValue: filterConfig.minimumValue,
            maximumValue: filterConfig.maximumValue,
            unit: filterConfig.unit,
            usesSmallNumberInputFont: filterConfig.usesSmallNumberInputFont
        )

        rangeNumberInputView.translatesAutoresizingMaskIntoConstraints = false
        rangeNumberInputView.delegate = self

        return rangeNumberInputView
    }()

    private lazy var sliderInputView: RangeSliderView = {
        let rangeSliderView = RangeSliderView(filterConfig: filterConfig, formatter: formatter)
        rangeSliderView.translatesAutoresizingMaskIntoConstraints = false
        rangeSliderView.delegate = self
        return rangeSliderView
    }()

    private lazy var referenceValuesContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = false
        return view
    }()

    // MARK: - Init

    init(filterConfig: RangeFilterConfiguration) {
        self.filterConfig = filterConfig
        formatter = RangeFilterValueFormatter(unit: filterConfig.unit)
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard self.point(inside: point, with: event) else {
            if numberInputView.isFirstResponder {
                _ = numberInputView.resignFirstResponder()
            }

            return nil
        }

        for subview in subviews {
            let convertedPoint = subview.convert(point, from: self)
            if let hitView = subview.hitTest(convertedPoint, with: event) {
                return hitView
            }
        }

        return nil
    }

    override var accessibilityFrame: CGRect {
        didSet {
            sliderInputView.accessibilityFrame = accessibilityFrame
        }
    }

    override func layoutSubviews() {
        sliderInputView.layoutIfNeeded()
        referenceValueViews.forEach { view in
            let thumbRectForValue = sliderInputView.thumbRect(for: view.value)
            let leadingConstant = thumbRectForValue.midX - (view.frame.width / 2)
            view.leadingConstraint?.constant = leadingConstant
        }

        if shouldForceSmallFontSizeForNumberInput() {
            numberInputView.forceSmallInputFontSize()
        }
    }

    // MARK: - Values

    func setLowValue(_ value: Int?, animated: Bool) {
        let step = value.map { filterConfig.values.closestStep(for: $0) } ?? .lowerBound

        if let value = value {
            updateNumberInput(for: .low, with: value, hintText: "")
        } else {
            updateNumberInput(for: .low, with: step)
        }

        updateSliderLowValue(with: step)
    }

    func setHighValue(_ value: Int?, animated: Bool) {
        let step = value.map { filterConfig.values.closestStep(for: $0) } ?? .upperBound

        if let value = value {
            updateNumberInput(for: .high, with: value, hintText: "")
        } else {
            updateNumberInput(for: .high, with: step)
        }

        updateSliderHighValue(with: step)
    }
}

// MARK: - Private

extension RangeFilterView {
    private func setup() {
        addSubview(numberInputView)
        addSubview(sliderInputView)
        addSubview(referenceValuesContainer)

        NSLayoutConstraint.activate([
            numberInputView.topAnchor.constraint(equalTo: topAnchor),
            numberInputView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: .spacingS),
            numberInputView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -.spacingS),
            numberInputView.centerXAnchor.constraint(equalTo: centerXAnchor),

            sliderInputView.topAnchor.constraint(equalTo: numberInputView.bottomAnchor, constant: 50),
            sliderInputView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .spacingM),
            sliderInputView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.spacingM),

            referenceValuesContainer.topAnchor.constraint(equalTo: sliderInputView.bottomAnchor, constant: .spacingXS),
            referenceValuesContainer.leadingAnchor.constraint(equalTo: sliderInputView.leadingAnchor),
            referenceValuesContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            referenceValuesContainer.trailingAnchor.constraint(equalTo: sliderInputView.trailingAnchor),
        ])

        referenceValueViews = filterConfig.referenceValues.map { referenceValue in
            return SliderReferenceValueView(
                value: referenceValue,
                displayText: formatter.string(from: referenceValue) ?? ""
            )
        }

        referenceValueViews.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            referenceValuesContainer.addSubview(view)

            let leadingConstraint = view.leadingAnchor.constraint(equalTo: referenceValuesContainer.leadingAnchor)

            NSLayoutConstraint.activate([
                leadingConstraint,
                view.topAnchor.constraint(equalTo: referenceValuesContainer.topAnchor),
                view.bottomAnchor.constraint(equalTo: referenceValuesContainer.bottomAnchor),
            ])

            view.leadingConstraint = leadingConstraint
        }
    }

    private func updateSliderLowValue(with step: Step) {
        inputValues[.low] = step
        sliderInputView.setLowStep(step, animated: false)
    }

    private func updateSliderHighValue(with step: Step) {
        inputValues[.high] = step
        sliderInputView.setHighStep(step, animated: false)
    }

    private func updateNumberInput(for inputValue: InputValue, with step: Step) {
        let value = filterConfig.value(for: step)
        let newValue: Int
        let hintText: String

        if let value = value {
            newValue = value
            hintText = ""
        } else {
            if step == .lowerBound {
                newValue = filterConfig.minimumValue
                hintText = filterConfig.unit.lowerBoundText
            } else {
                newValue = filterConfig.maximumValue
                hintText = filterConfig.unit.upperBoundText
            }
        }

        updateNumberInput(for: inputValue, with: newValue, hintText: hintText)
    }

    private func updateNumberInput(for inputValue: InputValue, with newValue: Int, hintText: String) {
        switch inputValue {
        case .low:
            numberInputView.setLowValueHint(text: hintText)
            numberInputView.setLowValue(newValue, animated: false)
        case .high:
            numberInputView.setHighValue(newValue, animated: false)
            numberInputView.setHighValueHint(text: hintText)
        }
    }

    private func shouldForceSmallFontSizeForNumberInput() -> Bool {
        let iphone6ScreenWidth: CGFloat = 375
        return frame.width < iphone6ScreenWidth
    }
}

// MARK: - RangeNumberInputViewDelegate

extension RangeFilterView: RangeNumberInputViewDelegate {
    func rangeNumberInputView(_ view: RangeNumberInputView, didChangeLowValue value: Int?) {
        if let lowValue = value {
            let step = filterConfig.values.closestStep(for: lowValue)
            updateSliderLowValue(with: step)
            numberInputView.setLowValueHint(text: "")
            delegate?.rangeFilterView(self, didSetLowValue: lowValue)
        } else {
            updateSliderLowValue(with: .lowerBound)
            delegate?.rangeFilterView(self, didSetLowValue: nil)
        }

        if let highStep = inputValues[.high] {
            updateSliderHighValue(with: highStep)
        }
    }

    func rangeNumberInputView(_ view: RangeNumberInputView, didChangeHighValue value: Int?) {
        if let highValue = value {
            let step = filterConfig.values.closestStep(for: highValue)
            updateSliderHighValue(with: step)
            numberInputView.setHighValueHint(text: "")
            delegate?.rangeFilterView(self, didSetHighValue: highValue)
        } else {
            updateSliderHighValue(with: .upperBound)
            delegate?.rangeFilterView(self, didSetHighValue: nil)
        }

        if let lowStep = inputValues[.low] {
            updateSliderLowValue(with: lowStep)
        }
    }
}

// MARK: - RangeSliderViewDelegate

extension RangeFilterView: RangeSliderViewDelegate {
    func rangeSliderView(_ rangeSliderView: RangeSliderView, didChangeLowStep step: Step) {
        handleSliderUpdates(for: .low, step: step)
    }

    func rangeSliderView(_ rangeSliderView: RangeSliderView, didChangeHighStep step: Step) {
        handleSliderUpdates(for: .high, step: step)
    }

    private func handleSliderUpdates(for inputValue: InputValue, step: Step) {
        let didStepChange = inputValues[inputValue] != step

        if didStepChange {
            updateNumberInput(for: inputValue, with: step)
            inputValues[inputValue] = step
        }

        let value = filterConfig.value(for: step)

        if inputValue == .low {
            delegate?.rangeFilterView(self, didSetLowValue: value)
        } else {
            delegate?.rangeFilterView(self, didSetHighValue: value)
        }
    }
}
