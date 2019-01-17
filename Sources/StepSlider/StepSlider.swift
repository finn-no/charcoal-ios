//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol StepSliderDelegate: AnyObject {
    func stepSlider<StepValueKind>(_ stepSlider: StepSlider<StepValueKind>, didChangeValue value: Float)
    func stepSlider<StepValueKind>(_ stepSlider: StepSlider<StepValueKind>, didChangeRoundedStepValue value: StepValueKind)
    func stepSlider<StepValueKind>(_ stepSlider: StepSlider<StepValueKind>, didEndSlideInteraction value: StepValueKind)
}

class StepSlider<StepValueKind: Comparable>: UISlider {
    let range: [StepValueKind]
    var generatesHapticFeedbackOnValueChange = true

    private var previousRoundedStepValue: StepValueKind?
    weak var delegate: StepSliderDelegate?
    private let valueFormatter: SliderValueFormatter
    private let accessibilityStepIncrement: Float
    private let lowerBoundStepValue: StepValueKind?
    private let upperBoundStepValue: StepValueKind?
    private let leftSideOffset: Float

    // MARK: - Init

    init(range: [StepValueKind],
         valueFormatter: SliderValueFormatter,
         lowerBoundOffsetValue: StepValueKind? = nil,
         upperBoundOffsetValue: StepValueKind? = nil,
         accessibilityStepIncrement: Int = 1) {
        self.range = range
        self.valueFormatter = valueFormatter
        self.accessibilityStepIncrement = Float(accessibilityStepIncrement)

        let minimumValue = Float(0)
        let maximumValue = Float(range.count - 1)

        let sideOffset = maximumValue * 0.025
        lowerBoundStepValue = lowerBoundOffsetValue
        upperBoundStepValue = upperBoundOffsetValue

        leftSideOffset = lowerBoundOffsetValue != nil ? sideOffset : 0
        let rightSideOffset = upperBoundOffsetValue != nil ? sideOffset : 0

        super.init(frame: .zero)

        minimumTrackTintColor = .clear
        maximumTrackTintColor = .clear
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue + leftSideOffset + rightSideOffset
        setThumbImage(RangeSliderView.Style.sliderThumbImage, for: .normal)
        setThumbImage(RangeSliderView.Style.activeSliderThumbImage, for: .highlighted)
        addTarget(self, action: #selector(sliderValueChanged(sender:event:)), for: .valueChanged)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var currentTrackRect: CGRect {
        return trackRect(forBounds: bounds)
    }

    var currentThumbRect: CGRect {
        return thumbRect(forBounds: bounds, trackRect: currentTrackRect, value: value)
    }

    var roundedStepValue: StepValueKind? {
        return roundedStepValue(fromValue: value)
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
        value = translateValueToNormalizedRangeStartingFromZeroValue(value: newValue)
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
        if let index = range.firstIndex(of: value) {
            return Float(index) + leftSideOffset
        } else if let last = range.last, value > last {
            return maximumValue
        } else if let first = range.first, value < first {
            return minimumValue
        } else {
            return 0
        }
    }

    private func roundedStepValue(fromValue value: Float) -> StepValueKind? {
        let index = Int(roundf(value) - leftSideOffset)

        if let stepValue = range[safe: index] {
            return stepValue
        } else if value > Float(range.count - 1) {
            return upperBoundStepValue
        } else if value < leftSideOffset {
            return lowerBoundStepValue
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
