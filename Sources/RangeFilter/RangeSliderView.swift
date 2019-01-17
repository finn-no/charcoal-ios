//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol RangeSliderViewDelegate: AnyObject {
    func rangeSliderView(_ rangeSliderView: RangeSliderView, didChangeLowValue: RangeSliderView.RangeValue?)
    func rangeSliderView(_ rangeSliderView: RangeSliderView, didChangeHighValue: RangeSliderView.RangeValue?)
}

final class RangeSliderView: UIControl {
    public static let minimumViewHeight: CGFloat = 28.0

    private lazy var lowValueSlider = makeStepSlider()
    private lazy var highValueSlider = makeStepSlider()

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
    let sliderInfo: StepSliderInfo<RangeValue>
    let formatter: SliderValueFormatter

    var generatesHapticFeedbackOnValueChange = true {
        didSet {
            lowValueSlider.generatesHapticFeedbackOnValueChange = generatesHapticFeedbackOnValueChange
            highValueSlider.generatesHapticFeedbackOnValueChange = generatesHapticFeedbackOnValueChange
        }
    }

    override var accessibilityFrame: CGRect {
        didSet {
            lowValueSlider.accessibilityFrame = accessibilityFrame
            highValueSlider.accessibilityFrame = accessibilityFrame
        }
    }

    weak var delegate: RangeSliderViewDelegate?

    init(sliderInfo: StepSliderInfo<RangeValue>, formatter: SliderValueFormatter) {
        self.sliderInfo = sliderInfo
        self.formatter = formatter
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

    override func layoutSubviews() {
        super.layoutSubviews()

        updateActiveTrackRange()
    }

    private func makeStepSlider() -> StepSlider<RangeValue> {
        let slider = StepSlider(
            range: sliderInfo.effectiveValues,
            valueFormatter: formatter, accessibilityStepIncrement: sliderInfo.accessibilityStepIncrement
        )
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.delegate = self
        return slider
    }
}

extension RangeSliderView: RangeControl {
    var lowValue: RangeValue? {
        guard var lowValue = lowValueSlider.roundedStepValue else {
            return nil
        }

        if let highValue = highValueSlider.roundedStepValue {
            lowValue = min(lowValue, highValue)
        }

        if lowValue < sliderInfo.minimumValue {
            return nil
        }

        return lowValue
    }

    var highValue: RangeValue? {
        guard var highValue = highValueSlider.roundedStepValue else {
            return nil
        }

        if let lowValue = lowValueSlider.roundedStepValue {
            highValue = max(lowValue, highValue)
        }

        if highValue > sliderInfo.maximumValue {
            return nil
        }

        return highValue
    }

    func setLowValue(_ value: RangeValue, animated: Bool) {
        lowValueSlider.setValueForSlider(value, animated: animated)
        updateActiveTrackRange()
        updateAccesibilityValues()
    }

    func setHighValue(_ value: RangeValue, animated: Bool) {
        highValueSlider.setValueForSlider(value, animated: animated)
        updateActiveTrackRange()
        updateAccesibilityValues()
    }

    func thumbRect(for value: RangeValue) -> CGRect {
        let bounds = lowValueSlider.bounds
        let trackRect = lowValueSlider.trackRect(forBounds: bounds)
        let translatedValue = lowValueSlider.translateValueToNormalizedRangeStartingFromZeroValue(value: value)
        let thumbRect = lowValueSlider.thumbRect(forBounds: bounds, trackRect: trackRect, value: Float(translatedValue))

        let rectOffsetingInvisibleThumbPadding = thumbRect.offsetBy(dx: -2, dy: 0)

        return rectOffsetingInvisibleThumbPadding
    }
}

extension RangeSliderView {
    struct Style {
        static let trackColor: UIColor = .sardine
        static let activeRangeTrackColor: UIColor = .primaryBlue
        static let sliderThumbImage: UIImage? = UIImage(named: .sliderThumb)
        static let activeSliderThumbImage: UIImage? = UIImage(named: .sliderThumbActive)
        static let trackHeight: CGFloat = 3.0
        static let activeRangeTrackHeight: CGFloat = 6.0
    }
}

private extension RangeSliderView {
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

    var lowestValueSlider: StepSlider<RangeValue> {
        return lowValueSlider.value <= highValueSlider.value ? lowValueSlider : highValueSlider
    }

    var highestValueSlider: StepSlider<RangeValue> {
        return highValueSlider.value >= lowValueSlider.value ? highValueSlider : lowValueSlider
    }

    func updateActiveTrackRange() {
        if frame == CGRect.zero {
            return
        }

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

// extension RangeSliderView: SteppedSliderDelegate {
//    func steppedSlider(_ steppedSlider: SteppedSlider, didChangeRoundedStepValue value: RangeSliderView.RangeValue) {
//        if steppedSlider == highestValueSlider {
//            delegate?.rangeSliderView(self, didChangeHighValue: highValue)
//        } else {
//            delegate?.rangeSliderView(self, didChangeLowValue: lowValue)
//        }
//    }
//
//    func steppedSlider(_ steppedSlider: SteppedSlider, didChangeValue value: Float) {
//        updateActiveTrackRange()
//        updateAccesibilityValues()
//    }
// }

extension RangeSliderView: StepSliderDelegate {
    func stepSlider<StepValueKind>(_ stepSlider: StepSlider<StepValueKind>, didChangeValue value: Float) {
        updateActiveTrackRange()
        updateAccesibilityValues()
    }

    func stepSlider<StepValueKind>(_ stepSlider: StepSlider<StepValueKind>, didChangeRoundedStepValue value: StepValueKind) {
        if stepSlider == highestValueSlider {
            delegate?.rangeSliderView(self, didChangeHighValue: highValue)
        } else {
            delegate?.rangeSliderView(self, didChangeLowValue: lowValue)
        }
    }

    func stepSlider<StepValueKind>(_ stepSlider: StepSlider<StepValueKind>, didEndSlideInteraction value: StepValueKind) where StepValueKind: Comparable {
        if stepSlider == highestValueSlider {
            delegate?.rangeSliderView(self, didChangeHighValue: highValue)
        } else {
            delegate?.rangeSliderView(self, didChangeLowValue: lowValue)
        }
    }
}
