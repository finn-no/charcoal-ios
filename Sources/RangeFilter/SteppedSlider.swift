//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol SteppedSliderDelegate: AnyObject {
    func steppedSlider(_ steppedSlider: SteppedSlider, didChangeValue value: Float)
    func steppedSlider(_ steppedSlider: SteppedSlider, didChangeRoundedStepValue value: RangeSliderView.RangeValue)
}

class SteppedSlider: UISlider {
    let steps: Int
    let range: RangeSliderView.SliderRange
    let effectiveRange: RangeSliderView.SliderRange
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
    weak var delegate: SteppedSliderDelegate?

    init(data: StepSliderData<RangeSliderView.RangeValue>) {
        range = data.range
        effectiveRange = data.effectiveRange
        steps = data.steps
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
        delegate?.steppedSlider(self, didChangeValue: value)
    }

    override func accessibilityDecrement() {
        let decrementedValue = roundedStepValue - accessibilityStepIncrement
        value = Float(decrementedValue)
        updateAccessibilityValue()
        delegate?.steppedSlider(self, didChangeValue: value)
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
            delegate?.steppedSlider(self, didChangeRoundedStepValue: newValue)

            updateAccessibilityValue()

            if generatesHapticFeedbackOnValueChange && shouldGenerateFeedBack {
                generateFeedback()
            }
        } else {
            value = Float(newValue)
            previousRoundedStepValue = newValue
            updateAccessibilityValue()
        }
        delegate?.steppedSlider(self, didChangeValue: value)
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
}
