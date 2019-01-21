//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol StepSliderDelegate: AnyObject {
    func stepSlider<StepValueKind>(_ stepSlider: StepSlider<StepValueKind>, didChangeValue value: Float)
    func stepSlider<StepValueKind>(_ stepSlider: StepSlider<StepValueKind>, canChangeToRoundedStepValue value: StepValueKind) -> Bool
    func stepSlider<StepValueKind>(_ stepSlider: StepSlider<StepValueKind>, didChangeRoundedStepValue value: StepValueKind)
    func stepSlider<StepValueKind>(_ stepSlider: StepSlider<StepValueKind>, didEndSlideInteraction value: StepValueKind)
}

class StepSlider<StepValueKind: Comparable & Numeric>: UISlider {
    let range: [StepValueKind]
    var generatesHapticFeedbackOnValueChange = true

    private var previousValue: Float = 0
    private var previousRoundedStepValue: StepValueKind?
    weak var delegate: StepSliderDelegate?
    private let valueFormatter: SliderValueFormatter
    private let accessibilityStepIncrement: Float
    private let maximumValueWithoutOffset: Float
    private let lowerBoundStepValue: StepValueKind?
    private let upperBoundStepValue: StepValueKind?
    private let leftSideOffset: Float

    // MARK: - Init

    init(range: [StepValueKind],
         valueFormatter: SliderValueFormatter,
         minimumStepValueWithOffset: StepValueKind? = nil,
         maximumStepValueWithOffset: StepValueKind? = nil,
         accessibilityStepIncrement: Int = 1) {
        self.range = range
        self.valueFormatter = valueFormatter
        self.accessibilityStepIncrement = Float(accessibilityStepIncrement)
        maximumValueWithoutOffset = Float(range.count - 1)
        lowerBoundStepValue = minimumStepValueWithOffset ?? range.first
        upperBoundStepValue = maximumStepValueWithOffset ?? range.last

        let sideOffset = maximumValueWithoutOffset * 0.05

        leftSideOffset = minimumStepValueWithOffset != nil ? sideOffset : 0
        let rightSideOffset = maximumStepValueWithOffset != nil ? sideOffset : 0

        super.init(frame: .zero)

        minimumTrackTintColor = .clear
        maximumTrackTintColor = .clear
        minimumValue = 0
        maximumValue = maximumValueWithoutOffset + leftSideOffset + rightSideOffset
        setThumbImage(RangeSliderView.Style.sliderThumbImage, for: .normal)
        setThumbImage(RangeSliderView.Style.activeSliderThumbImage, for: .highlighted)
        addTarget(self, action: #selector(sliderValueChanged(sender:event:)), for: .valueChanged)
    }

    convenience init(sliderInfo: StepSliderInfo<StepValueKind>, valueFormatter: SliderValueFormatter) {
        self.init(
            range: sliderInfo.values,
            valueFormatter: valueFormatter,
            minimumStepValueWithOffset: sliderInfo.hasLowerBoundOffset ? sliderInfo.minimumValueWithOffset : nil,
            maximumStepValueWithOffset: sliderInfo.hasUpperBoundOffset ? sliderInfo.maximumValueWithOffset : nil,
            accessibilityStepIncrement: sliderInfo.accessibilityStepIncrement
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Slider

    var currentTrackRect: CGRect {
        return trackRect(forBounds: bounds)
    }

    var currentThumbRect: CGRect {
        return thumbRect(forBounds: bounds, trackRect: currentTrackRect, value: value)
    }

    var roundedStepValue: StepValueKind? {
        return roundedStepValue(fromValue: value)
    }

    func setValueForSlider(_ findResult: StepValueResult<StepValueKind>, animated: Bool) {
        switch findResult {
        case let .exact(match):
            setValueForSlider(match, animated: animated)
        case let .between(_, lower, _):
            let adjust: Float = 0.5
            let sliderValue = translateValueToNormalizedRangeStartingFromZeroValue(value: lower)
            setValueForSlider(sliderValue + adjust, animated: animated)
        case let .tooLow(closest):
            let value = lowerBoundStepValue ?? closest
            let sliderValue = translateValueToNormalizedRangeStartingFromZeroValue(value: value)
            setValueForSlider(sliderValue, animated: animated)
        case let .tooHigh(closest):
            let value = upperBoundStepValue ?? closest
            let sliderValue = translateValueToNormalizedRangeStartingFromZeroValue(value: value)
            setValueForSlider(sliderValue, animated: animated)
        }
    }

    func setValueForSlider(_ value: StepValueKind, animated: Bool) {
        let translatedValue = translateValueToNormalizedRangeStartingFromZeroValue(value: value)
        setValueForSlider(translatedValue, animated: animated)
    }

    func setValueForSlider(_ value: Float, animated: Bool) {
        previousRoundedStepValue = nil
        setValue(value, animated: animated)
        updateAccessibilityValue()
    }

    @objc func sliderValueChanged(sender slider: UISlider, event: UIEvent) {
        let slideEnded: Bool
        if let touch = event.allTouches?.first, touch.phase != .ended {
            slideEnded = false
        } else {
            slideEnded = true
        }

        guard let newValue = roundedStepValue(fromValue: slider.value) else {
            return
        }

        guard delegate?.stepSlider(self, canChangeToRoundedStepValue: newValue) ?? true else {
            value = previousValue
            return
        }

        value = rangeValue(from: newValue) ?? slider.value
        previousValue = value

        let stepChanged = previousRoundedStepValue != nil && previousRoundedStepValue != newValue
        if previousRoundedStepValue == nil || stepChanged {
            delegate?.stepSlider(self, didChangeRoundedStepValue: newValue)

            if generatesHapticFeedbackOnValueChange {
                generateFeedback()
            }
        }
        previousRoundedStepValue = newValue
        updateAccessibilityValue()
        delegate?.stepSlider(self, didChangeValue: value)

        if slideEnded {
            delegate?.stepSlider(self, didEndSlideInteraction: newValue)
        }
    }

    override func accessibilityDecrement() {
        guard let decrementTo = roundedStepValue(fromValue: value - accessibilityStepIncrement) else {
            return
        }
        setValueForSlider(decrementTo, animated: false)
        sendActions(for: .valueChanged)
    }

    override func accessibilityIncrement() {
        guard let incrementTo = roundedStepValue(fromValue: value + accessibilityStepIncrement) else {
            return
        }
        setValueForSlider(incrementTo, animated: false)
        sendActions(for: .valueChanged)
    }

    func translateValueToNormalizedRangeStartingFromZeroValue(value: StepValueKind) -> Float {
        if let rangeValue = self.rangeValue(from: value) {
            return rangeValue
        } else if let last = range.last, value > last {
            return maximumValue
        } else {
            return minimumValue
        }
    }

    private func rangeValue(from value: StepValueKind) -> Float? {
        return range.firstIndex(of: value).map({ Float($0) + leftSideOffset })
    }

    private func roundedStepValue(fromValue value: Float) -> StepValueKind? {
        let valueWithoutOffset = roundf(value - leftSideOffset)
        let index = Int(valueWithoutOffset)

        if valueWithoutOffset < minimumValue {
            return lowerBoundStepValue
        } else if valueWithoutOffset > maximumValueWithoutOffset {
            return upperBoundStepValue
        } else if let stepValue = range[safe: index] {
            return stepValue
        } else {
            return nil
        }
    }

    private func updateAccessibilityValue() {
        accessibilityValue = valueFormatter.accessibilityValue(for: value)
    }

    private func generateFeedback() {
        if #available(iOS 10.0, *) {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }
}
