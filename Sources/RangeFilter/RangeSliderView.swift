//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

final class RangeSliderView: UIControl {
    public static let minimumViewHeight: CGFloat = 28.0

    private lazy var lowValueSlider: SteppedSlider = {
        let slider = SteppedSlider(range: range, additionalLowerBoundOffset: additionalLowerBoundOffset, additionalUpperBoundOffset: additionalUpperBoundOffset, steps: steps)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        slider.roundedStepValueChangedHandler = roundedStepValueChanged

        return slider
    }()

    private lazy var highValueSlider: SteppedSlider = {
        let slider = SteppedSlider(range: range, additionalLowerBoundOffset: additionalLowerBoundOffset, additionalUpperBoundOffset: additionalUpperBoundOffset, steps: steps)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        slider.roundedStepValueChangedHandler = roundedStepValueChanged

        return slider
    }()

    private lazy var trackView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Style.trackColor
        view.layer.cornerRadius = 1.0

        return view
    }()

    private lazy var activeRangeTrackView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Style.activeRangeTrackColor

        return view
    }()

    private let activeRangeTrackViewLeadingAnchorIdentifier = "activeRangeTrackViewLeadingAnchorIdentifier"
    private let activeRangeTrackViewTrailingAnchorIdentifier = "activeRangeTrackViewTrailingAnchorIdentifier"

    typealias RangeValue = Int
    typealias SliderRange = ClosedRange<RangeValue>
    let range: SliderRange
    let additionalLowerBoundOffset: RangeValue
    let additionalUpperBoundOffset: RangeValue
    let steps: Int

    var generatesHapticFeedbackOnValueChange = true {
        didSet {
            lowValueSlider.generatesHapticFeedbackOnValueChange = generatesHapticFeedbackOnValueChange
            highValueSlider.generatesHapticFeedbackOnValueChange = generatesHapticFeedbackOnValueChange
        }
    }

    var accessibilityValueSuffix: String? {
        didSet {
            lowValueSlider.accessibilityValueSuffix = accessibilityValueSuffix
            highValueSlider.accessibilityValueSuffix = accessibilityValueSuffix
        }
    }

    private var _accessibilitySteps: Int?
    var accessibilitySteps: Int {
        get {
            guard let accessibilitySteps = _accessibilitySteps else {
                return steps
            }

            return accessibilitySteps
        }
        set {
            _accessibilitySteps = newValue
            lowValueSlider.accessibilitySteps = newValue
            highValueSlider.accessibilitySteps = newValue
        }
    }

    override var accessibilityFrame: CGRect {
        didSet {
            lowValueSlider.accessibilityFrame = accessibilityFrame
            highValueSlider.accessibilityFrame = accessibilityFrame
        }
    }

    init(range: SliderRange, additionalLowerBoundOffset: RangeValue, additionalUpperBoundOffset: RangeValue, steps: Int?) {
        self.range = range
        self.additionalLowerBoundOffset = additionalLowerBoundOffset
        self.additionalUpperBoundOffset = additionalUpperBoundOffset
        self.steps = steps ?? Int(range.upperBound - range.lowerBound)
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

        if lowValueSlider.currentThumbRect.contains(point) {
            return lowValueSlider
        } else if highValueSlider.currentThumbRect.contains(point) {
            return highValueSlider
        } else {
            return self
        }
    }
}

extension RangeSliderView: RangeControl {
    var lowValue: RangeValue? {
        return RangeSliderView.RangeValue(min(lowValueSlider.value, highValueSlider.value))
    }

    var highValue: RangeValue? {
        return RangeSliderView.RangeValue(max(lowValueSlider.value, highValueSlider.value))
    }

    func setLowValue(_ value: RangeValue, animated: Bool) {
        lowestValueSlider.setValueForSlider(value, animated: animated)
        updateActiveTrackRange()
        updateAccesibilityValues()
    }

    func setHighValue(_ value: RangeValue, animated: Bool) {
        highestValueSlider.setValueForSlider(value, animated: animated)
        updateActiveTrackRange()
        updateAccesibilityValues()
    }

    func thumbRect(for value: RangeValue) -> CGRect {
        let bounds = lowValueSlider.bounds
        let trackRect = lowValueSlider.trackRect(forBounds: bounds)
        let thumbRect = lowValueSlider.thumbRect(forBounds: bounds, trackRect: trackRect, value: Float(value))

        let rectOffsetingInvisibleThumbPadding = thumbRect.offsetBy(dx: -2, dy: 0)

        return rectOffsetingInvisibleThumbPadding
    }
}

private extension RangeSliderView {
    struct Style {
        static let trackColor: UIColor = .sardine
        static let activeRangeTrackColor: UIColor = .primaryBlue
        static let sliderThumbImage: UIImage? = UIImage(named: .sliderThumb)
        static let activeSliderThumbImage: UIImage? = UIImage(named: .sliderThumbActive)
        static let trackHeight: CGFloat = 3.0
        static let activeRangeTrackHeight: CGFloat = 6.0
    }

    func setup() {
        activeRangeTrackView.isHidden = true
        addSubview(trackView)
        addSubview(activeRangeTrackView)
        addSubview(lowValueSlider)
        addSubview(highValueSlider)

        lowValueSlider.fillInSuperview()
        highValueSlider.fillInSuperview()

        let activeRangeTrackViewLeadingAnchor = activeRangeTrackView.leadingAnchor.constraint(equalTo: leadingAnchor)
        activeRangeTrackViewLeadingAnchor.identifier = activeRangeTrackViewLeadingAnchorIdentifier

        let activeRangeTrackViewTrailingAnchor = activeRangeTrackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        activeRangeTrackViewTrailingAnchor.identifier = activeRangeTrackViewTrailingAnchorIdentifier

        NSLayoutConstraint.activate([
            trackView.leadingAnchor.constraint(equalTo: lowValueSlider.leadingAnchor, constant: .verySmallSpacing),
            trackView.trailingAnchor.constraint(equalTo: lowValueSlider.trailingAnchor, constant: -.verySmallSpacing),
            trackView.centerYAnchor.constraint(equalTo: lowValueSlider.centerYAnchor),
            trackView.heightAnchor.constraint(equalToConstant: Style.trackHeight),
            activeRangeTrackViewLeadingAnchor,
            activeRangeTrackViewTrailingAnchor,
            activeRangeTrackView.centerYAnchor.constraint(equalTo: lowValueSlider.centerYAnchor),
            activeRangeTrackView.heightAnchor.constraint(equalToConstant: Style.activeRangeTrackHeight),
        ])

        accessibilityElements = [lowValueSlider, highValueSlider]
        updateAccesibilityValues()
    }

    func roundedStepValueChanged(_ slider: SteppedSlider) {
        sendActions(for: .valueChanged)
    }

    @objc func sliderValueChanged(_ slider: SteppedSlider) {
        updateActiveTrackRange()
        updateAccesibilityValues()
    }

    var lowestValueSlider: SteppedSlider {
        return lowValueSlider.value <= highValueSlider.value ? lowValueSlider : highValueSlider
    }

    var highestValueSlider: SteppedSlider {
        return highValueSlider.value >= lowValueSlider.value ? highValueSlider : lowValueSlider
    }

    func updateActiveTrackRange() {
        let leadingConstant = lowestValueSlider.currentThumbRect.midX
        let trailingConstant = highestValueSlider.currentThumbRect.midX - trackView.bounds.width
        let activeRangeTrackViewLeadingAnchor = constraints.filter({ $0.identifier == activeRangeTrackViewLeadingAnchorIdentifier }).first
        let activeRangeTrackViewTrailingAnchor = constraints.filter({ $0.identifier == activeRangeTrackViewTrailingAnchorIdentifier }).first

        activeRangeTrackViewLeadingAnchor?.constant = leadingConstant
        activeRangeTrackViewTrailingAnchor?.constant = trailingConstant

        activeRangeTrackView.layoutIfNeeded()
        activeRangeTrackView.isHidden = false
    }

    func updateAccesibilityValues() {
        lowestValueSlider.accessibilityLabel = "range_slider_view_low_value_slider_accessibility_label".localized()
        highestValueSlider.accessibilityLabel = "range_slider_view_high_value_slider_accessibility_label".localized()
    }
}

fileprivate final class SteppedSlider: UISlider {
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
        minimumValue = Float(effectiveRange.lowerBound)
        maximumValue = Float(effectiveRange.upperBound)
        setThumbImage(RangeSliderView.Style.sliderThumbImage, for: .normal)
        setThumbImage(RangeSliderView.Style.activeSliderThumbImage, for: .highlighted)
        addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        addTarget(self, action: #selector(sliderStoppedTracking), for: .touchUpInside)
        accessibilityValue = "\(minimumValue) \(accessibilityValueSuffix ?? "")"
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
        return roundedStepValue(fromValue: RangeSliderView.RangeValue(value))
    }

    func setValueForSlider(_ value: RangeSliderView.RangeValue, animated: Bool) {
        let roundedStepValue = self.roundedStepValue(fromValue: value)
        setValue(Float(roundedStepValue), animated: animated)
        updateAccessibilityValue()
    }

    @objc func sliderValueChanged(sender: SteppedSlider) {
        let newValue = RangeSliderView.RangeValue(roundedStepValue)

        if let previousValue = previousRoundedStepValue, previousValue != newValue {
            let offsetValue = self.offsetValue(for: newValue, checkedAgaints: previousValue)
            let isLowerBoundStepValue = (newValue == range.lowerBound || newValue == effectiveRange.lowerBound)
            let isUpperBoundStepValue = (newValue == range.upperBound || newValue == effectiveRange.upperBound)
            let isNonOffsetValue = range.contains(newValue)
            let shouldNotifyValueChanged = isNonOffsetValue || isLowerBoundStepValue || isUpperBoundStepValue

            if shouldNotifyValueChanged {
                value = Float(offsetValue)
                previousRoundedStepValue = offsetValue
                roundedStepValueChangedHandler?(self)
            }

            updateAccessibilityValue()

            if generatesHapticFeedbackOnValueChange && shouldNotifyValueChanged {
                generateFeedback()
            }

        } else {
            value = Float(newValue)
            previousRoundedStepValue = newValue
            updateAccessibilityValue()
        }
    }

    @objc func sliderStoppedTracking(sender: SteppedSlider) {
        let newValue = RangeSliderView.RangeValue(roundedStepValue)

        if let previousValue = previousRoundedStepValue {
            if newValue < previousValue && newValue > range.upperBound {
                value = Float(range.upperBound)
            } else if newValue > previousValue && newValue > range.upperBound {
                value = Float(effectiveRange.upperBound)
            } else if newValue > previousValue && newValue < range.lowerBound {
                value = Float(range.lowerBound)
            } else if newValue < previousValue && newValue < range.lowerBound {
                value = Float(effectiveRange.lowerBound)
            } else {
                value = Float(newValue)
            }
        } else {
            value = Float(newValue)
        }

        previousRoundedStepValue = newValue
        roundedStepValueChangedHandler?(self)

        if generatesHapticFeedbackOnValueChange {
            generateFeedback()
        }
    }

    func offsetValue(for value: RangeSliderView.RangeValue, checkedAgaints previousValue: RangeSliderView.RangeValue) -> RangeSliderView.RangeValue {
        let isLowerOffsetValue = (effectiveRange.lowerBound ..< range.lowerBound) ~= value
        let isUpperOffsetValue = ((range.upperBound.advanced(by: 1)) ... effectiveRange.upperBound) ~= value
        let isOffsetValue = isLowerOffsetValue || isUpperOffsetValue

        if isOffsetValue && isLowerOffsetValue {
            return (previousValue > value) ? range.lowerBound : effectiveRange.lowerBound
        } else if isOffsetValue && isUpperOffsetValue {
            return (value > previousValue) ? effectiveRange.upperBound : range.upperBound
        } else {
            return value
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
