//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import UIKit

protocol ValueSliderViewDelegate: AnyObject {
    func valueViewControl(_ valueSliderView: ValueSliderView, didChangeValue: Int, didFinishSlideInteraction: Bool)
}

class ValueSliderView: UIView {
    private lazy var valueSlider: StepSlider = {
        let slider = StepSlider(numberOfSteps: range.count - 1)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.delegate = self
        return slider
    }()

    private lazy var trackView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ValueSliderViewStyle.trackColor
        view.layer.cornerRadius = 1.0

        return view
    }()

    private lazy var activeRangeTrackView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ValueSliderViewStyle.activeRangeTrackColor

        return view
    }()

    private lazy var referenceValuesContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = false
        return view
    }()

    private var referenceValueViews = [SliderReferenceValueView]()

    private let activeRangeTrackViewTrailingAnchorIdentifier = "activeRangeTrackViewTrailingAnchorIdentifier"

    let range: [Int]

    var generatesHapticFeedbackOnValueChange = true {
        didSet {
            valueSlider.generatesHapticFeedbackOnValueChange = generatesHapticFeedbackOnValueChange
        }
    }

    override var accessibilityFrame: CGRect {
        didSet {
            valueSlider.accessibilityFrame = accessibilityFrame
        }
    }

    weak var delegate: ValueSliderViewDelegate?

    private var previousValueSliderFrame: CGRect = .zero

    private let valueFormatter: SliderValueFormatter

    private let referenceValueIndexes: [Int]

    init(range: [Int], referenceValueIndexes: [Int], valueFormatter: SliderValueFormatter) {
        self.range = range
        self.referenceValueIndexes = referenceValueIndexes
        self.valueFormatter = valueFormatter
        super.init(frame: .zero)
        setup()
    }

    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard self.point(inside: point, with: event) else {
            return nil
        }

        if valueSlider.currentThumbRect.contains(point) {
            return valueSlider
        } else {
            return self
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateActiveTrackRange()

        if valueSlider.frame != previousValueSliderFrame {
            setNeedsUpdateConstraints()
        }
        previousValueSliderFrame = valueSlider.frame
    }

    override func updateConstraints() {
        super.updateConstraints()
        referenceValueViews.forEach { view in
            let thumbRectForValue = thumbRect(for: view.value)
            view.midXConstraint?.constant = thumbRectForValue.midX
        }
    }
}

extension ValueSliderView {
    func setCurrentValue(_ value: Int, animated: Bool) {
        let step = range.closestStep(for: value)
        valueSlider.setStep(step, animated: animated)
        updateActiveTrackRange()
        updateAccesibilityValues()
    }

    func thumbRect(for stepValue: Int) -> CGRect {
        let bounds = valueSlider.bounds
        let trackRect = valueSlider.trackRect(forBounds: bounds)
        let closestStep = range.closestStep(for: stepValue)
        let translatedValue = valueSlider.value(from: closestStep)
        let thumbRect = valueSlider.thumbRect(forBounds: bounds, trackRect: trackRect, value: translatedValue)

        let convertedRect = valueSlider.convert(thumbRect, to: self)
        return convertedRect
    }
}

struct ValueSliderViewStyle {
    static let trackColor: UIColor = .btnDisabled
    static let activeRangeTrackColor: UIColor = .nmpBrandControlSelected
    static let trackHeight: CGFloat = 3.0
    static let activeRangeTrackHeight: CGFloat = 6.0
}

private extension ValueSliderView {
    func setup() {
        activeRangeTrackView.isHidden = true
        addSubview(trackView)
        addSubview(activeRangeTrackView)
        addSubview(valueSlider)
        addSubview(referenceValuesContainer)

        let referenceViewsConstraints = setupReferenceValueView()

        let activeRangeTrackViewLeadingAnchor = activeRangeTrackView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor)

        let activeRangeTrackViewTrailingAnchor = activeRangeTrackView.trailingAnchor.constraint(equalTo: trackView.trailingAnchor)
        activeRangeTrackViewTrailingAnchor.identifier = activeRangeTrackViewTrailingAnchorIdentifier

        NSLayoutConstraint.activate([
            valueSlider.topAnchor.constraint(equalTo: topAnchor),
            valueSlider.leadingAnchor.constraint(equalTo: leadingAnchor),
            valueSlider.trailingAnchor.constraint(equalTo: trailingAnchor),

            trackView.leadingAnchor.constraint(equalTo: valueSlider.leadingAnchor, constant: .spacingXXS),
            trackView.trailingAnchor.constraint(equalTo: valueSlider.trailingAnchor, constant: -.spacingXXS),
            trackView.centerYAnchor.constraint(equalTo: valueSlider.centerYAnchor),
            trackView.heightAnchor.constraint(equalToConstant: ValueSliderViewStyle.trackHeight),
            activeRangeTrackViewLeadingAnchor,
            activeRangeTrackViewTrailingAnchor,
            activeRangeTrackView.centerYAnchor.constraint(equalTo: valueSlider.centerYAnchor),
            activeRangeTrackView.heightAnchor.constraint(equalToConstant: ValueSliderViewStyle.activeRangeTrackHeight),

            referenceValuesContainer.topAnchor.constraint(equalTo: valueSlider.bottomAnchor, constant: .spacingXS),
            referenceValuesContainer.leadingAnchor.constraint(equalTo: valueSlider.leadingAnchor),
            referenceValuesContainer.trailingAnchor.constraint(equalTo: valueSlider.trailingAnchor),
            referenceValuesContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
        ] + referenceViewsConstraints)

        accessibilityElements = [valueSlider]
        updateAccesibilityValues()
    }

    func setupReferenceValueView() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        referenceValueViews = referenceValueIndexes.map { index in
            let referenceValue = range[index]
            return SliderReferenceValueView(value: referenceValue, displayText: valueFormatter.title(for: referenceValue))
        }

        referenceValueViews.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            referenceValuesContainer.addSubview(view)

            let centerXConstraint = view.centerXAnchor.constraint(equalTo: referenceValuesContainer.leadingAnchor)

            constraints.append(contentsOf: [
                centerXConstraint,
                view.topAnchor.constraint(equalTo: referenceValuesContainer.topAnchor),
                view.bottomAnchor.constraint(equalTo: referenceValuesContainer.bottomAnchor),
            ])

            view.midXConstraint = centerXConstraint
        }
        return constraints
    }

    func updateActiveTrackRange() {
        if frame == CGRect.zero {
            return
        }

        let trailingConstant = valueSlider.currentThumbRect.midX - trackView.bounds.width
        let activeRangeTrackViewTrailingAnchor = constraints.filter { $0.identifier == activeRangeTrackViewTrailingAnchorIdentifier }.first

        activeRangeTrackViewTrailingAnchor?.constant = trailingConstant

        activeRangeTrackView.layoutIfNeeded()
        activeRangeTrackView.isHidden = false
    }

    func updateAccesibilityValues() {
        valueSlider.accessibilityLabel = "map.valueSliderAccessibilityLabel".localized()
    }
}

extension ValueSliderView: StepSliderDelegate {
    func stepSlider(_ stepSlider: StepSlider, didChangeRawValue value: Float) {
        updateActiveTrackRange()
        updateAccesibilityValues()
    }

    func stepSlider(_ stepSlider: StepSlider, canChangeToStep step: Step) -> Bool {
        return true
    }

    func stepSlider(_ stepSlider: StepSlider, didChangeStep step: Step) {
        if let value = range.value(for: step) {
            delegate?.valueViewControl(self, didChangeValue: value, didFinishSlideInteraction: false)
        }
    }

    func stepSlider(_ stepSlider: StepSlider, didEndSlideInteraction step: Step) {
        if let value = range.value(for: step) {
            delegate?.valueViewControl(self, didChangeValue: value, didFinishSlideInteraction: true)
        }
    }

    func stepSlider(_ stepSlider: StepSlider, accessibilityValueForStep step: Step) -> String {
        if let value = range.value(for: step) {
            return valueFormatter.accessibilityValue(for: value)
        } else {
            return ""
        }
    }
}
