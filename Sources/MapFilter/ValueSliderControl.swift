//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol ValueSliderControlDelegate: AnyObject {
    func valueSliderControl(_ valueSliderControl: ValueSliderControl, didChangeValue: StepValue?)
}

final class ValueSliderControl: UIControl {
    public static let minimumViewHeight: CGFloat = 28.0

    private lazy var valueSlider: StepSlider = {
        let slider = StepSlider(range: range)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.delegate = self
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

    private let activeRangeTrackViewTrailingAnchorIdentifier = "activeRangeTrackViewTrailingAnchorIdentifier"

    let range: [StepValue]

    var generatesHapticFeedbackOnValueChange = true {
        didSet {
            valueSlider.generatesHapticFeedbackOnValueChange = generatesHapticFeedbackOnValueChange
        }
    }

    override var accessibilityFrame: CGRect {
        didSet {
            valueSlider.accessibilityFrame = accessibilityFrame
        }
    }

    weak var delegate: ValueSliderControlDelegate?

    init(range: [StepValue]) {
        self.range = range
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

        if valueSlider.currentThumbRect.contains(point) {
            return valueSlider
        } else {
            return self
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateActiveTrackRange()
    }
}

extension ValueSliderControl {
    var currentValue: StepValue? {
        let value = valueSlider.roundedStepValue
        return value
    }

    func setCurrentValue(_ value: StepValue, animated: Bool) {
        valueSlider.setValueForSlider(value, animated: animated)
        updateActiveTrackRange()
        updateAccesibilityValues()
    }

    func thumbRect(for value: StepValue) -> CGRect {
        let bounds = valueSlider.bounds
        let trackRect = valueSlider.trackRect(forBounds: bounds)
        let translatedValue = valueSlider.translateValueToNormalizedRangeStartingFromZeroValue(value: value)
        let thumbRect = valueSlider.thumbRect(forBounds: bounds, trackRect: trackRect, value: translatedValue)

        return thumbRect
    }
}

extension ValueSliderControl {
    struct Style {
        static let trackColor: UIColor = .sardine
        static let activeRangeTrackColor: UIColor = .primaryBlue
        static let sliderThumbImage: UIImage? = UIImage(named: .sliderThumb)
        static let activeSliderThumbImage: UIImage? = UIImage(named: .sliderThumbActive)
        static let trackHeight: CGFloat = 3.0
        static let activeRangeTrackHeight: CGFloat = 6.0
    }
}

private extension ValueSliderControl {
    func setup() {
        activeRangeTrackView.isHidden = true
        addSubview(trackView)
        addSubview(activeRangeTrackView)
        addSubview(valueSlider)

        valueSlider.fillInSuperview()

        let activeRangeTrackViewLeadingAnchor = activeRangeTrackView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor)

        let activeRangeTrackViewTrailingAnchor = activeRangeTrackView.trailingAnchor.constraint(equalTo: trackView.trailingAnchor)
        activeRangeTrackViewTrailingAnchor.identifier = activeRangeTrackViewTrailingAnchorIdentifier

        NSLayoutConstraint.activate([
            trackView.leadingAnchor.constraint(equalTo: valueSlider.leadingAnchor, constant: .verySmallSpacing),
            trackView.trailingAnchor.constraint(equalTo: valueSlider.trailingAnchor, constant: -.verySmallSpacing),
            trackView.centerYAnchor.constraint(equalTo: valueSlider.centerYAnchor),
            trackView.heightAnchor.constraint(equalToConstant: Style.trackHeight),
            activeRangeTrackViewLeadingAnchor,
            activeRangeTrackViewTrailingAnchor,
            activeRangeTrackView.centerYAnchor.constraint(equalTo: valueSlider.centerYAnchor),
            activeRangeTrackView.heightAnchor.constraint(equalToConstant: Style.activeRangeTrackHeight),
        ])

        accessibilityElements = [valueSlider]
        updateAccesibilityValues()
    }

    func updateActiveTrackRange() {
        if frame == CGRect.zero {
            return
        }

        let trailingConstant = valueSlider.currentThumbRect.midX - trackView.bounds.width
        let activeRangeTrackViewTrailingAnchor = constraints.filter({ $0.identifier == activeRangeTrackViewTrailingAnchorIdentifier }).first

        activeRangeTrackViewTrailingAnchor?.constant = trailingConstant

        activeRangeTrackView.layoutIfNeeded()
        activeRangeTrackView.isHidden = false
    }

    func updateAccesibilityValues() {
        valueSlider.accessibilityLabel = "value_slider_control_value_slider_accessibility_label".localized()
    }
}

extension ValueSliderControl: StepSliderDelegate {
    func stepSlider(_ stepSlider: StepSlider, didChangeValue value: Float) {
        updateActiveTrackRange()
        updateAccesibilityValues()
    }

    func stepSlider(_ stepSlider: StepSlider, didChangeRoundedStepValue value: StepValue) {
        delegate?.valueSliderControl(self, didChangeValue: value)
    }
}
