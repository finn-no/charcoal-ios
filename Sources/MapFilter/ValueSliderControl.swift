//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public struct StepValue<StepValueKind: Comparable>: Equatable, Comparable, SliderReferenceValue {
    let value: StepValueKind
    let displayText: String
    var isReferenceValue: Bool

    init(value: StepValueKind, displayText: String, isReferenceValue: Bool = false) {
        self.value = value
        self.displayText = displayText
        self.isReferenceValue = isReferenceValue
    }

    public static func < (lhs: StepValue, rhs: StepValue) -> Bool {
        return lhs.value < rhs.value
    }
}

typealias ValueSliderControlValueKind = Comparable & Numeric

protocol ValueSliderControlDelegate: AnyObject {
    func valueSliderControl<ValueKind: ValueSliderControlValueKind>(_ valueSliderControl: ValueSliderControl<ValueKind>, didChangeValue: StepValue<ValueKind>)
}

final class ValueSliderControl<ValueKind: ValueSliderControlValueKind>: UIControl {
    private lazy var valueSlider: StepSlider<StepValue<ValueKind>> = {
        let slider = StepSlider<StepValue<ValueKind>>(range: range)
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

    init(range: [StepValue<ValueKind>]) {
        self.range = range
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
            guard let value = view.value as? ValueKind, let step = findClosestStepInRange(with: value) else {
                return
            }
            let thumbRectForValue = thumbRect(for: step)
            view.midXConstraint?.constant = thumbRectForValue.midX
        })
    }
}

extension ValueSliderControl {
    var currentClosestStepValue: StepValue<ValueKind>? {
        guard let step = findClosestStepInRange(with: valueSlider.roundedStepValue?.value) else {
            return nil
        }
        return step
    }

    func setCurrentValue(_ value: StepValue<ValueKind>, animated: Bool) {
        valueSlider.setValueForSlider(value, animated: animated)
        updateActiveTrackRange()
        updateAccesibilityValues()
    }

    func setCurrentValue(_ value: Float, animated: Bool) {
        valueSlider.setValueForSlider(value, animated: animated)
        updateActiveTrackRange()
        updateAccesibilityValues()
    }

    func findClosestStepInRange(with value: ValueKind?) -> StepValue<ValueKind>? {
        guard let value = value, let firstRange = range.first, let lastRange = range.last else {
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
