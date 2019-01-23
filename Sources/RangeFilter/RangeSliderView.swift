//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol RangeSliderViewDelegate: AnyObject {
    func rangeSliderView(_ rangeSliderView: RangeSliderView, didChangeLowValue: Int?, didFinishSlideInteraction slideEnded: Bool)
    func rangeSliderView(_ rangeSliderView: RangeSliderView, didChangeHighValue: Int?, didFinishSlideInteraction slideEnded: Bool)
}

final class RangeSliderView: UIControl {
    private static var visibleThumbWidth: CGFloat = 28

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

    typealias SliderRange = ClosedRange<Int>
    private let sliderInfo: StepSliderInfo
    private let formatter: SliderValueFormatter

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

    init(sliderInfo: StepSliderInfo, formatter: SliderValueFormatter) {
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

        let lowPoint = point
        let highPoint = CGPoint(x: point.x - RangeSliderView.visibleThumbWidth, y: point.y)

        if lowValueSlider.currentThumbRect.contains(lowPoint) {
            return lowValueSlider
        } else if highValueSlider.currentThumbRect.contains(highPoint) {
            return highValueSlider
        } else {
            return self
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateActiveTrackRange()
    }

    private func makeStepSlider() -> StepSlider {
        let slider = StepSlider(sliderInfo: sliderInfo, valueFormatter: formatter)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.delegate = self
        return slider
    }
}

extension RangeSliderView: RangeControl {
    var lowValue: Int? {
        guard let lowValue = lowValueSlider.roundedStepValue, lowValue >= sliderInfo.minimumValue else {
            return nil
        }

        return lowValue
    }

    var highValue: Int? {
        guard let highValue = highValueSlider.roundedStepValue, highValue <= sliderInfo.maximumValue else {
            return nil
        }

        return highValue
    }

    func setLowValue(_ value: Int, animated: Bool) {
        let value = highValueSlider.roundedStepValue.map({ $0 < value ? $0 : value }) ?? value

        guard let findResult = sliderInfo.values.findClosestStep(for: value) else {
            return
        }

        lowValueSlider.setValueForSlider(findResult, animated: animated)
        updateActiveTrackRange()
        updateAccesibilityValues()
    }

    func setHighValue(_ value: Int, animated: Bool) {
        let value = lowValueSlider.roundedStepValue.map({ $0 > value ? $0 : value }) ?? value

        guard let findResult = sliderInfo.values.findClosestStep(for: value) else {
            return
        }

        highValueSlider.setValueForSlider(findResult, animated: animated)
        updateActiveTrackRange()
        updateAccesibilityValues()
    }

    func thumbRect(for value: Int) -> CGRect {
        let bounds = lowValueSlider.bounds
        let trackRect = lowValueSlider.trackRect(forBounds: bounds)
        let translatedValue = lowValueSlider.translateValueToNormalizedRangeStartingFromZeroValue(value: value)
        let thumbRect = lowValueSlider.thumbRect(forBounds: bounds, trackRect: trackRect, value: Float(translatedValue))

        let thumbRadius = RangeSliderView.visibleThumbWidth / 2 - 2
        let rectOffsetingInvisibleThumbPadding = thumbRect.offsetBy(dx: thumbRadius, dy: 0)

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

        let activeRangeTrackViewLeadingAnchor = activeRangeTrackView.leadingAnchor.constraint(equalTo: leadingAnchor)
        activeRangeTrackViewLeadingAnchor.identifier = activeRangeTrackViewLeadingAnchorIdentifier

        let activeRangeTrackViewTrailingAnchor = activeRangeTrackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        activeRangeTrackViewTrailingAnchor.identifier = activeRangeTrackViewTrailingAnchorIdentifier

        let sliderOffset = RangeSliderView.visibleThumbWidth

        NSLayoutConstraint.activate([
            lowValueSlider.topAnchor.constraint(equalTo: topAnchor),
            lowValueSlider.bottomAnchor.constraint(equalTo: bottomAnchor),
            lowValueSlider.leadingAnchor.constraint(equalTo: leadingAnchor),
            lowValueSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -sliderOffset),

            highValueSlider.topAnchor.constraint(equalTo: topAnchor),
            highValueSlider.bottomAnchor.constraint(equalTo: bottomAnchor),
            highValueSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: sliderOffset),
            highValueSlider.trailingAnchor.constraint(equalTo: trailingAnchor),

            trackView.leadingAnchor.constraint(equalTo: lowValueSlider.leadingAnchor, constant: .verySmallSpacing),
            trackView.trailingAnchor.constraint(equalTo: highValueSlider.trailingAnchor, constant: -.verySmallSpacing),
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

    func updateActiveTrackRange() {
        if frame == CGRect.zero {
            return
        }

        let leadingConstant = lowValueSlider.currentThumbRect.midX
        let trailingConstant = highValueSlider.currentThumbRect.midX - highValueSlider.bounds.maxX
        let activeRangeTrackViewLeadingAnchor = constraints.filter({ $0.identifier == activeRangeTrackViewLeadingAnchorIdentifier }).first
        let activeRangeTrackViewTrailingAnchor = constraints.filter({ $0.identifier == activeRangeTrackViewTrailingAnchorIdentifier }).first

        activeRangeTrackViewLeadingAnchor?.constant = leadingConstant
        activeRangeTrackViewTrailingAnchor?.constant = trailingConstant

        activeRangeTrackView.layoutIfNeeded()
        activeRangeTrackView.isHidden = false
    }

    func updateAccesibilityValues() {
        lowValueSlider.accessibilityLabel = "range_slider_view_low_value_slider_accessibility_label".localized()
        highValueSlider.accessibilityLabel = "range_slider_view_high_value_slider_accessibility_label".localized()
    }
}

extension RangeSliderView: StepSliderDelegate {
    func stepSlider(_ stepSlider: StepSlider, didChangeValue value: Float) {
        updateActiveTrackRange()
        updateAccesibilityValues()
    }

    func stepSlider(_ stepSlider: StepSlider, canChangeToRoundedStepValue value: Int) -> Bool {
        if let lowValue = lowValue, stepSlider == highValueSlider {
            return value >= lowValue
        } else if let highValue = highValue, stepSlider == lowValueSlider {
            return value <= highValue
        } else {
            return true
        }
    }

    func stepSlider(_ stepSlider: StepSlider, didChangeRoundedStepValue value: Int) {
        if lowValueSlider.roundedStepValue == highValueSlider.roundedStepValue, generatesHapticFeedbackOnValueChange {
            FeedbackGenerator.generate(.collision)
        }

        if stepSlider == highValueSlider {
            delegate?.rangeSliderView(self, didChangeHighValue: highValue, didFinishSlideInteraction: false)
        } else {
            delegate?.rangeSliderView(self, didChangeLowValue: lowValue, didFinishSlideInteraction: false)
        }
    }

    func stepSlider(_ stepSlider: StepSlider, didEndSlideInteraction value: Int) {
        if stepSlider == highValueSlider {
            delegate?.rangeSliderView(self, didChangeHighValue: highValue, didFinishSlideInteraction: true)
        } else {
            delegate?.rangeSliderView(self, didChangeLowValue: lowValue, didFinishSlideInteraction: true)
        }
    }
}
