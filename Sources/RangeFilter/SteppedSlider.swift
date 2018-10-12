//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class SteppedSlider: UISlider {
    let steps: Int
    let range: RangeSliderView.SliderRange
    let effectiveRange: RangeSliderView.SliderRange

    var roundedStepValueChangedHandler: ((SteppedSlider) -> Void)?
    var generatesHapticFeedbackOnValueChange = true

    var accessibilityValueSuffix: String? {
        didSet {
            accessibilityValue = "\(roundedStepValue) \(accessibilityValueSuffix ?? "")"
        }
    }

    private var _accessibilitySteps: Int?
    public var accessibilitySteps: Int {
        get {
            guard let accessibilitySteps = _accessibilitySteps else {
                return steps
            }

            return accessibilitySteps
        }
        set {
            _accessibilitySteps = newValue
        }
    }

    private var previousRoundedStepValue: RangeSliderView.RangeValue?

    init(range: RangeSliderView.SliderRange, additionalLowerBoundOffset: RangeSliderView.RangeValue = 0, additionalUpperBoundOffset: RangeSliderView.RangeValue = 0, steps: Int) {
        self.range = range
        effectiveRange = SteppedSlider.effectiveRange(from: range, with: additionalLowerBoundOffset, and: additionalUpperBoundOffset)
        self.steps = steps
        super.init(frame: .zero)

        minimumTrackTintColor = .clear
        maximumTrackTintColor = .clear
        let normalizedRange = normalizedRangeStartingFromZero()
        minimumValue = Float(normalizedRange.lowerBound)
        maximumValue = Float(normalizedRange.upperBound)
        setThumbImage(RangeSliderView.Style.sliderThumbImage, for: .normal)
        setThumbImage(RangeSliderView.Style.activeSliderThumbImage, for: .highlighted)
        addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        accessibilityValue = "\(minimumValue) \(accessibilityValueSuffix ?? "")"
    }

    func normalizedRangeStartingFromZero() -> RangeSliderView.SliderRange {
        if effectiveRange.lowerBound >= 0 {
            return effectiveRange
        }
        let lowerBound = RangeSliderView.RangeValue(0)
        let upperBound = effectiveRange.upperBound + abs(effectiveRange.lowerBound)

        return lowerBound ... upperBound
    }

    func translateValueFromNormalizedRangeStartingFromZeroValue(_ value: RangeSliderView.RangeValue) -> RangeSliderView.RangeValue {
        if effectiveRange == normalizedRangeStartingFromZero() {
            return value
        }

        let translatedValue = value - abs(effectiveRange.lowerBound)

        return translatedValue
    }

    func translateValueToNormalizedRangeStartingFromZeroValue(value: RangeSliderView.RangeValue) -> RangeSliderView.RangeValue {
        if effectiveRange == normalizedRangeStartingFromZero() {
            return value
        }

        let translatedValue = value + abs(effectiveRange.lowerBound)

        return translatedValue
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func accessibilityIncrement() {
        let incrementedValue = roundedStepValue + accessibilityStepIncrement
        value = Float(incrementedValue)
        updateAccessibilityValue()
        sendActions(for: .valueChanged)
    }

    override func accessibilityDecrement() {
        let decrementedValue = roundedStepValue - accessibilityStepIncrement
        value = Float(decrementedValue)
        updateAccessibilityValue()
        sendActions(for: .valueChanged)
    }

    var currentTrackRect: CGRect {
        return trackRect(forBounds: bounds)
    }

    var currentThumbRect: CGRect {
        return thumbRect(forBounds: bounds, trackRect: currentTrackRect, value: value)
    }

    var roundedStepValue: RangeSliderView.RangeValue {
        let stepValue = roundedStepValue(fromValue: RangeSliderView.RangeValue(value))
        let translatedStepValue = translateValueFromNormalizedRangeStartingFromZeroValue(stepValue)
        return translatedStepValue
    }

    func setValueForSlider(_ value: RangeSliderView.RangeValue, animated: Bool) {
        let roundedStepValue = self.roundedStepValue(fromValue: value)
        let translatedValue = translateValueToNormalizedRangeStartingFromZeroValue(value: roundedStepValue)
        setValue(Float(translatedValue), animated: animated)
        updateAccessibilityValue()
    }

    @objc func sliderValueChanged(sender: SteppedSlider) {
        let newValue = roundedStepValue(fromValue: RangeSliderView.RangeValue(sender.value))

        if let previousValue = previousRoundedStepValue, previousValue != newValue {
            let translatedValue = translateValueFromNormalizedRangeStartingFromZeroValue(newValue)
            let isLowerOffsetValue = translatedValue == effectiveRange.lowerBound
            let isUpperOffsetValue = translatedValue == effectiveRange.upperBound
            let isNonOffsetValue = range.contains(translatedValue)
            let shouldGenerateFeedBack = isNonOffsetValue || isLowerOffsetValue || isUpperOffsetValue

            value = Float(newValue)
            previousRoundedStepValue = newValue
            roundedStepValueChangedHandler?(self)
            roundedStepValueChangedHandler?(self)

            updateAccessibilityValue()

            if generatesHapticFeedbackOnValueChange && shouldGenerateFeedBack {
                generateFeedback()
            }
        } else {
            value = Float(newValue)
            previousRoundedStepValue = newValue
            updateAccessibilityValue()
        }
    }

    private var accessibilityStepIncrement: Int {
        return (effectiveRange.upperBound - effectiveRange.lowerBound) / RangeSliderView.RangeValue(accessibilitySteps)
    }

    private var stepIncrement: Int {
        return (effectiveRange.upperBound - effectiveRange.lowerBound) / RangeSliderView.RangeValue(steps)
    }

    func roundedStepValue(fromValue value: RangeSliderView.RangeValue) -> RangeSliderView.RangeValue {
        return (value / stepIncrement) * stepIncrement
    }

    private func updateAccessibilityValue() {
        accessibilityValue = "\(roundedStepValue) \(accessibilityValueSuffix ?? "")"
    }

    private func generateFeedback() {
        if #available(iOS 10.0, *) {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }

    static func effectiveRange(from range: RangeSliderView.SliderRange, with lowerBoundOffset: RangeSliderView.RangeValue, and upperBoundOffset: RangeSliderView.RangeValue) -> RangeSliderView.SliderRange {
        let newLowerBound = range.lowerBound - lowerBoundOffset
        let newUpperBound = range.upperBound + upperBoundOffset

        return RangeSliderView.SliderRange(newLowerBound ... newUpperBound)
    }
}
