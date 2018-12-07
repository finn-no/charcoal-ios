//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol StepSliderDelegate: AnyObject {
    func stepSlider<StepValueKind>(_ stepSlider: StepSlider<StepValueKind>, didChangeValue value: Float)
    func stepSlider<StepValueKind>(_ stepSlider: StepSlider<StepValueKind>, didChangeRoundedStepValue value: StepValueKind)
}

class StepSlider<StepValueKind: Comparable>: UISlider {
    let range: [StepValueKind]
    var generatesHapticFeedbackOnValueChange = true

    private var previousRoundedStepValue: StepValueKind?
    weak var delegate: StepSliderDelegate?

    init(range: [StepValueKind]) {
        self.range = range

        super.init(frame: .zero)

        minimumTrackTintColor = .clear
        maximumTrackTintColor = .clear
        minimumValue = Float(0)
        maximumValue = Float(range.count - 1)
        setThumbImage(RangeSliderView.Style.sliderThumbImage, for: .normal)
        setThumbImage(RangeSliderView.Style.activeSliderThumbImage, for: .highlighted)
        addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    }

    func translateValueToNormalizedRangeStartingFromZeroValue(value: StepValueKind) -> Float {
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

    var roundedStepValue: StepValueKind? {
        let stepValue = roundedStepValue(fromValue: value)
        return stepValue
    }

    func setValueForSlider(_ value: StepValueKind, animated: Bool) {
        let translatedValue = Float(range.firstIndex(of: value) ?? 0)
        setValue(translatedValue, animated: animated)
        updateAccessibilityValue()
    }

    func setValueForSlider(_ value: Float, animated: Bool) {
        setValue(value, animated: animated)
        updateAccessibilityValue()
    }

    @objc func sliderValueChanged(sender: UISlider) {
        guard let newValue = roundedStepValue(fromValue: sender.value) else {
            return
        }
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

    func roundedStepValue(fromValue value: Float) -> StepValueKind? {
        let index = Int(roundf(value))
        return range[safe: index]
    }

    private func updateAccessibilityValue() {
        accessibilityValue = "\(roundedStepValue)" // TODO: need to use .value and a formatter
    }

    private func generateFeedback() {
        if #available(iOS 10.0, *) {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }
}
