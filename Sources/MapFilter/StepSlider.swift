//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public struct StepValue: Equatable, Hashable, Comparable {
    let value: Int
    let displayTitle: String

    public static func < (lhs: StepValue, rhs: StepValue) -> Bool {
        return lhs.value < rhs.value
    }
}

protocol StepSliderDelegate: AnyObject {
    func stepSlider(_ stepSlider: StepSlider, didChangeValue value: Float)
    func stepSlider(_ stepSlider: StepSlider, didChangeRoundedStepValue value: StepValue)
}

class StepSlider: UISlider {
    let range: [StepValue]
    var generatesHapticFeedbackOnValueChange = true
    let firstValue: StepValue

    private var previousRoundedStepValue: StepValue?
    weak var delegate: StepSliderDelegate?

    init(range: [StepValue]) {
        self.range = range
        if let firstValue = range.first {
            self.firstValue = firstValue
        } else {
            firstValue = StepValue(value: 0, displayTitle: "")
        }

        super.init(frame: .zero)

        minimumTrackTintColor = .clear
        maximumTrackTintColor = .clear
        minimumValue = Float(0)
        maximumValue = Float(range.count - 1)
        setThumbImage(RangeSliderView.Style.sliderThumbImage, for: .normal)
        setThumbImage(RangeSliderView.Style.activeSliderThumbImage, for: .highlighted)
        addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        accessibilityValue = firstValue.displayTitle
    }

    func translateValueToNormalizedRangeStartingFromZeroValue(value: StepValue) -> Float {
        return Float(range.firstIndex(of: value) ?? 0)
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

    var roundedStepValue: StepValue {
        let stepValue = roundedStepValue(fromValue: value)
        return stepValue
    }

    func setValueForSlider(_ value: StepValue, animated: Bool) {
        let translatedValue = Float(range.firstIndex(of: roundedStepValue) ?? 0)
        setValue(translatedValue, animated: animated)
        updateAccessibilityValue()
    }

    @objc func sliderValueChanged(sender: StepSlider) {
        let newValue = roundedStepValue(fromValue: sender.value)
        value = Float(range.firstIndex(of: newValue) ?? 0)

        if let previousValue = previousRoundedStepValue, previousValue != newValue {
            delegate?.stepSlider(self, didChangeRoundedStepValue: newValue)

            if generatesHapticFeedbackOnValueChange {
                generateFeedback()
            }
        }
        previousRoundedStepValue = newValue
        updateAccessibilityValue()
        delegate?.stepSlider(self, didChangeValue: value)
    }

    private var accessibilityStepIncrement: Int {
        return 1
    }

    private var stepIncrement: Int {
        return 1
    }

    func roundedStepValue(fromValue value: Float) -> StepValue {
        let index = Int(roundf(value))
        return range[safe: index] ?? firstValue
    }

    private func updateAccessibilityValue() {
        accessibilityValue = roundedStepValue.displayTitle
    }

    private func generateFeedback() {
        if #available(iOS 10.0, *) {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }
}
