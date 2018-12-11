//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

typealias SliderValueKind = Comparable & Numeric

protocol ValueSliderControlDelegate: AnyObject {
    func valueSliderControl<ValueKind: SliderValueKind>(_ valueSliderControl: ValueSliderControl<ValueKind>, didChangeValue: StepValue<ValueKind>)
}

class ValueSliderControl<ValueKind: SliderValueKind>: UIControl {
    enum StepValueFindResult {
        case exact(stepValue: StepValue<ValueKind>)
        case between(closest: StepValue<ValueKind>, lower: StepValue<ValueKind>, higher: StepValue<ValueKind>)
        case tooLow(closest: StepValue<ValueKind>)
        case tooHigh(closest: StepValue<ValueKind>)

        var closestStep: StepValue<ValueKind> {
            switch self {
            case let .exact(stepValue):
                return stepValue
            case let .between(closest, _, _):
                return closest
            case let .tooLow(closest):
                return closest
            case let .tooHigh(closest):
                return closest
            }
        }
    }

    private lazy var valueSlider: StepSlider<StepValue<ValueKind>> = {
        let slider = StepSlider<StepValue<ValueKind>>(range: range, valueFormatter: valueFormatter)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.delegate = self
        return slider
    }()

    private lazy var trackView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ValueSliderControlStyle.trackColor
        view.layer.cornerRadius = 1.0

        return view
    }()

    private lazy var activeRangeTrackView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ValueSliderControlStyle.activeRangeTrackColor

        return view
    }()

    private lazy var referenceValuesContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = false
        return view
    }()

    private var referenceValueViews = [SliderReferenceValueView<StepValue<ValueKind>>]()

    private let activeRangeTrackViewTrailingAnchorIdentifier = "activeRangeTrackViewTrailingAnchorIdentifier"

    let range: [StepValue<ValueKind>]

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

    weak var delegate: ValueSliderControlDelegate?

    private var previousValueSliderFrame: CGRect = .zero

    private let valueFormatter: SliderValueFormatter

    init(range: [StepValue<ValueKind>], valueFormatter: SliderValueFormatter) {
        self.range = range
        self.valueFormatter = valueFormatter
        super.init(frame: .zero)
        setup()
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
        referenceValueViews.forEach({ view in
            let thumbRectForValue = thumbRect(for: view.value)
            view.midXConstraint?.constant = thumbRectForValue.midX
        })
    }
}

extension ValueSliderControl {
    var currentClosestStepValue: StepValue<ValueKind>? {
        guard let findResult = findClosestStepInRange(for: valueSlider.roundedStepValue?.value) else {
            return nil
        }
        return findResult.closestStep
    }

    func setCurrentValue(_ value: ValueKind, animated: Bool) {
        guard let findResult = findClosestStepInRange(for: value) else {
            return
        }
        switch findResult {
        case let .exact(match):
            valueSlider.setValueForSlider(match, animated: animated)
        case let .between(_, lower, _):
            let adjust: Float = 0.5
            let sliderValue = valueSlider.translateValueToNormalizedRangeStartingFromZeroValue(value: lower)
            valueSlider.setValueForSlider(sliderValue + adjust, animated: animated)
        case let .tooLow(closest):
            let sliderValue = valueSlider.translateValueToNormalizedRangeStartingFromZeroValue(value: closest)
            valueSlider.setValueForSlider(sliderValue, animated: animated)
        case let .tooHigh(closest):
            let sliderValue = valueSlider.translateValueToNormalizedRangeStartingFromZeroValue(value: closest)
            valueSlider.setValueForSlider(sliderValue, animated: animated)
        }

        updateActiveTrackRange()
        updateAccesibilityValues()
    }

    func findClosestStepInRange(for value: ValueKind?) -> StepValueFindResult? {
        guard let value = value, let firstInRange = range.first, let lastInRange = range.last else {
            return nil
        }
        let result: StepValueFindResult
        if let higherOrEqualStepIndex = range.firstIndex(where: { $0.value >= value }) {
            let higherOrEqualStep = range[higherOrEqualStepIndex]
            let diffToHigherStep = higherOrEqualStep.value - value
            if diffToHigherStep == 0 {
                result = .exact(stepValue: higherOrEqualStep)
            } else if let lowerStep = range[safe: higherOrEqualStepIndex - 1] {
                let closestStep: StepValue<ValueKind>
                let diffToLowerStep = lowerStep.value - value
                if diffToLowerStep < diffToHigherStep {
                    closestStep = lowerStep
                } else {
                    closestStep = higherOrEqualStep
                }
                result = .between(closest: closestStep, lower: lowerStep, higher: higherOrEqualStep)
            } else {
                result = .tooLow(closest: firstInRange)
            }
        } else {
            result = .tooHigh(closest: lastInRange)
        }
        return result
    }

    func thumbRect(for stepValue: StepValue<ValueKind>) -> CGRect {
        let bounds = valueSlider.bounds
        let trackRect = valueSlider.trackRect(forBounds: bounds)
        let translatedValue = valueSlider.translateValueToNormalizedRangeStartingFromZeroValue(value: stepValue)
        let thumbRect = valueSlider.thumbRect(forBounds: bounds, trackRect: trackRect, value: translatedValue)

        let convertedRect = valueSlider.convert(thumbRect, to: self)
        return convertedRect
    }
}

struct ValueSliderControlStyle {
    static let trackColor: UIColor = .sardine
    static let activeRangeTrackColor: UIColor = .primaryBlue
    static let sliderThumbImage: UIImage? = UIImage(named: .sliderThumb)
    static let activeSliderThumbImage: UIImage? = UIImage(named: .sliderThumbActive)
    static let trackHeight: CGFloat = 3.0
    static let activeRangeTrackHeight: CGFloat = 6.0
}

private extension ValueSliderControl {
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

            trackView.leadingAnchor.constraint(equalTo: valueSlider.leadingAnchor, constant: .verySmallSpacing),
            trackView.trailingAnchor.constraint(equalTo: valueSlider.trailingAnchor, constant: -.verySmallSpacing),
            trackView.centerYAnchor.constraint(equalTo: valueSlider.centerYAnchor),
            trackView.heightAnchor.constraint(equalToConstant: ValueSliderControlStyle.trackHeight),
            activeRangeTrackViewLeadingAnchor,
            activeRangeTrackViewTrailingAnchor,
            activeRangeTrackView.centerYAnchor.constraint(equalTo: valueSlider.centerYAnchor),
            activeRangeTrackView.heightAnchor.constraint(equalToConstant: ValueSliderControlStyle.activeRangeTrackHeight),

            referenceValuesContainer.topAnchor.constraint(equalTo: valueSlider.bottomAnchor, constant: .smallSpacing),
            referenceValuesContainer.leadingAnchor.constraint(equalTo: valueSlider.leadingAnchor),
            referenceValuesContainer.trailingAnchor.constraint(equalTo: valueSlider.trailingAnchor),
            referenceValuesContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
        ] + referenceViewsConstraints)

        accessibilityElements = [valueSlider]
        updateAccesibilityValues()
    }

    func setupReferenceValueView() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        let referenceValues: [StepValue<ValueKind>] = range.filter({ $0.isReferenceValue })
        referenceValueViews = referenceValues.compactMap({ (stepValue: StepValue<ValueKind>) -> SliderReferenceValueView<StepValue<ValueKind>>? in
            return SliderReferenceValueView<StepValue<ValueKind>>(value: stepValue)
        })

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
        let activeRangeTrackViewTrailingAnchor = constraints.filter({ $0.identifier == activeRangeTrackViewTrailingAnchorIdentifier }).first

        activeRangeTrackViewTrailingAnchor?.constant = trailingConstant

        activeRangeTrackView.layoutIfNeeded()
        activeRangeTrackView.isHidden = false
    }

    func updateAccesibilityValues() {
        valueSlider.accessibilityLabel = "value_slider_control_value_slider_accessibility_label".localized()
    }
}

extension ValueSliderControl: StepSliderDelegate {
    func stepSlider<StepValueKind>(_ stepSlider: StepSlider<StepValueKind>, didChangeValue value: Float) {
        updateActiveTrackRange()
        updateAccesibilityValues()
    }

    func stepSlider<StepValueKind>(_ stepSlider: StepSlider<StepValueKind>, didChangeRoundedStepValue value: StepValueKind) {
        guard let value = value as? StepValue<ValueKind> else {
            return
        }
        delegate?.valueSliderControl(self, didChangeValue: value)
    }
}
