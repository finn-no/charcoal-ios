//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol ValueSliderViewDelegate: AnyObject {
    func valueSliderView(_ valueSliderView: ValueSliderAndInputView, didSetValue value: Int)
}

public final class ValueSliderAndInputView: UIView {
    private lazy var valueLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .title2
        label.textColor = .licorice
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = " "
        return label
    }()

    private lazy var sliderControl: ValueSliderControl = {
        let sliderControl = ValueSliderControl(range: range)
        sliderControl.translatesAutoresizingMaskIntoConstraints = false
        sliderControl.delegate = self
        return sliderControl
    }()

    private lazy var referenceValuesContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = false
        return view
    }()

    public var generatesHapticFeedbackOnSliderValueChange = true {
        didSet {
            sliderControl.generatesHapticFeedbackOnValueChange = generatesHapticFeedbackOnSliderValueChange
        }
    }

    private var referenceValueViews = [RangeReferenceValueView]()

    var currentValue: RangeValue {
        return currentStepValue?.value ?? 0
    }

    private(set) var currentStepValue: StepValue? {
        didSet {
            updateLabel(with: currentStepValue)
            delegate?.valueSliderView(self, didSetValue: currentStepValue?.value ?? 0)
        }
    }

    public typealias RangeValue = Int
    let range: [StepValue]
    let referenceValues: [StepValue]

    public weak var delegate: ValueSliderViewDelegate?

    public init(range: [StepValue], referenceValueIndexes: [Int]) {
        self.range = range
        referenceValues = range.enumerated().compactMap({ return referenceValueIndexes.contains($0.offset) ? $0.element : nil })
        super.init(frame: .zero)
        setup()
        currentStepValue = range.first
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard self.point(inside: point, with: event) else {
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

    public override var accessibilityFrame: CGRect {
        didSet {
            sliderControl.accessibilityFrame = accessibilityFrame
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        referenceValueViews.forEach({ view in
            guard let step = findClosestStepInRange(with: view.value) else {
                return
            }
            let thumbRectForValue = sliderControl.thumbRect(for: step)
            let leadingConstant = thumbRectForValue.midX - (view.frame.width / 2)
            view.leadingConstraint?.constant = leadingConstant
        })
    }
}

extension ValueSliderAndInputView {
    public func setValue(_ value: RangeValue, animated: Bool) {
        guard let step = findClosestStepInRange(with: value) else {
            return
        }
        currentStepValue = step
    }
}

private extension ValueSliderAndInputView {
    func setup() {
        addSubview(valueLabel)
        addSubview(sliderControl)
        addSubview(referenceValuesContainer)

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: .mediumSpacing),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -.mediumSpacing),
            valueLabel.heightAnchor.constraint(equalToConstant: 32),
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            sliderControl.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: .mediumSpacing),
            sliderControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumLargeSpacing),
            sliderControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.mediumLargeSpacing),

            referenceValuesContainer.topAnchor.constraint(equalTo: sliderControl.bottomAnchor, constant: .smallSpacing),
            referenceValuesContainer.leadingAnchor.constraint(equalTo: sliderControl.leadingAnchor),
            referenceValuesContainer.trailingAnchor.constraint(equalTo: sliderControl.trailingAnchor),
            referenceValuesContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        referenceValueViews = referenceValues.map({ RangeReferenceValueView(value: $0.value, text: $0.displayTitle) })

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

    func findClosestStepInRange(with value: RangeValue) -> StepValue? {
        guard let firstRange = range.first, let lastRange = range.last else {
            return nil
        }
        if let higherOrEqualStepIndex = range.firstIndex(where: { $0.value >= value }) {
            let higherOrEqualStep = range[higherOrEqualStepIndex]
            let diffToHigherStep = higherOrEqualStep.value - value
            if diffToHigherStep == 0 {
                return higherOrEqualStep
            } else if let lowerStep = range[safe: higherOrEqualStepIndex - 1] {
                let diffToLowerStep = lowerStep.value - value
                if diffToLowerStep < diffToHigherStep {
                    return lowerStep
                } else {
                    return higherOrEqualStep
                }
            } else {
                return firstRange
            }
        } else {
            return lastRange
        }
    }

    private func updateLabel(with value: StepValue?) {
        guard let value = value else {
            valueLabel.text = ""
            return
        }
        valueLabel.text = value.displayTitle
    }
}

extension ValueSliderAndInputView: ValueSliderControlDelegate {
    func valueSliderControl(_ valueSliderControl: ValueSliderControl, didChangeValue value: StepValue?) {
        if let value = value {
            let didValueChange = currentValue != value.value
            if didValueChange {
                currentStepValue = value
                updateLabel(with: value)
                delegate?.valueSliderView(self, didSetValue: value.value)
            }
        } else {
            updateLabel(with: nil)
            delegate?.valueSliderView(self, didSetValue: 0)
        }
    }
}
