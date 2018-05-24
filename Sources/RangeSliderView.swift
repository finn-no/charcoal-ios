//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public final class RangeSliderView: UIControl {
    public static let minimumViewHeight: CGFloat = 28.0

    private lazy var lowValueSlider: SteppedSlider = {
        let slider = SteppedSlider(range: range, steps: steps)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        slider.roundedStepValueChangedHandler = roundedStepValueChanged

        return slider
    }()

    private lazy var highValueSlider: SteppedSlider = {
        let slider = SteppedSlider(range: range, steps: steps)
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

    public typealias RangeValue = Int
    public typealias SliderRange = ClosedRange<RangeValue>
    public let range: SliderRange

    public typealias Steps = Int
    public let steps: Int

    public var generatesHapticFeedbackOnValueChange = true {
        didSet {
            lowValueSlider.generatesHapticFeedbackOnValueChange = generatesHapticFeedbackOnValueChange
            highValueSlider.generatesHapticFeedbackOnValueChange = generatesHapticFeedbackOnValueChange
        }
    }

    public var accessibilityValueSuffix: String? {
        didSet {
            lowValueSlider.accessibilityValueSuffix = accessibilityValueSuffix
            highValueSlider.accessibilityValueSuffix = accessibilityValueSuffix
        }
    }

    private var _accessibilitySteps: Steps?
    public var accessibilitySteps: Steps {
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

    public init(range: SliderRange, steps: Steps?) {
        self.range = range
        self.steps = steps ?? Steps(range.upperBound - range.lowerBound)
        super.init(frame: .zero)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if lowValueSlider.currentThumbRect.contains(point) {
            return lowValueSlider
        } else if highValueSlider.currentThumbRect.contains(point) {
            return highValueSlider
        } else {
            return self
        }
    }
}

public extension RangeSliderView {
    var lowValue: RangeValue {
        return RangeSliderView.RangeValue(min(lowValueSlider.value, highValueSlider.value))
    }

    var highValue: RangeValue {
        return RangeSliderView.RangeValue(max(lowValueSlider.value, highValueSlider.value))
    }

    func setLowerValue(_ value: RangeValue, animated: Bool) {
        lowestValueSlider.setValueForSlider(value, animated: animated)
        updateActiveTrackRange()
    }

    func setUpperValue(_ value: RangeValue, animated: Bool) {
        highValueSlider.setValueForSlider(value, animated: animated)
        updateActiveTrackRange()
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
            trackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackView.trailingAnchor.constraint(equalTo: trailingAnchor),
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
    let steps: RangeSliderView.Steps
    let range: RangeSliderView.SliderRange

    var roundedStepValueChangedHandler: ((SteppedSlider) -> Void)?
    var generatesHapticFeedbackOnValueChange = true

    var accessibilityValueSuffix: String? {
        didSet {
            accessibilityValue = "\(roundedStepValue) \(accessibilityValueSuffix ?? "")"
        }
    }

    private var _accessibilitySteps: RangeSliderView.Steps?
    public var accessibilitySteps: RangeSliderView.Steps {
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

    init(range: RangeSliderView.SliderRange, steps: RangeSliderView.Steps) {
        self.range = range
        self.steps = steps
        super.init(frame: .zero)

        minimumTrackTintColor = .clear
        maximumTrackTintColor = .clear
        minimumValue = Float(range.lowerBound)
        maximumValue = Float(range.upperBound)
        setThumbImage(RangeSliderView.Style.sliderThumbImage, for: .normal)
        setThumbImage(RangeSliderView.Style.activeSliderThumbImage, for: .highlighted)

        addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)

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
        if let previousRoundedStepValue = previousRoundedStepValue, previousRoundedStepValue != roundedStepValue {
            value = Float(roundedStepValue)
            self.previousRoundedStepValue = roundedStepValue
            roundedStepValueChangedHandler?(self)
            updateAccessibilityValue()

            if generatesHapticFeedbackOnValueChange {
                generateFeedback()
            }
        } else {
            value = Float(roundedStepValue)
            previousRoundedStepValue = roundedStepValue
            updateAccessibilityValue()
        }
    }

    private var accessibilityStepIncrement: Int {
        return (range.upperBound - range.lowerBound) / RangeSliderView.RangeValue(accessibilitySteps)
    }

    private var stepIncrement: Int {
        return (range.upperBound - range.lowerBound) / RangeSliderView.RangeValue(steps)
    }

    private func roundedStepValue(fromValue value: RangeSliderView.RangeValue) -> RangeSliderView.RangeValue {
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
