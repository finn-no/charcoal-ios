//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol ValueSliderViewDelegate: AnyObject {
    func valueViewControl<ValueKind: SliderValueKind>(_ valueSliderView: ValueSliderView<ValueKind>, didChangeValue: ValueKind, didFinishSlideInteraction: Bool)
}

class ValueSliderView<ValueKind: SliderValueKind>: UIView {
    private lazy var valueSlider: StepSlider<ValueKind> = {
        let slider = StepSlider<ValueKind>(range: range, valueFormatter: valueFormatter)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.delegate = self
        return slider
    }()

    private lazy var trackView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ValueSliderViewStyle.trackColor
        view.layer.cornerRadius = 1.0

        return view
    }()

    private lazy var activeRangeTrackView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ValueSliderViewStyle.activeRangeTrackColor

        return view
    }()

    private lazy var referenceValuesContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = false
        return view
    }()

    private var referenceValueViews = [SliderReferenceValueView<ValueKind>]()

    private let activeRangeTrackViewTrailingAnchorIdentifier = "activeRangeTrackViewTrailingAnchorIdentifier"

    let range: [ValueKind]

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

    weak var delegate: ValueSliderViewDelegate?

    private var previousValueSliderFrame: CGRect = .zero

    private let valueFormatter: SliderValueFormatter

    private let referenceValueIndexes: [Int]

    init(range: [ValueKind], referenceValueIndexes: [Int], valueFormatter: SliderValueFormatter) {
        self.range = range
        self.referenceValueIndexes = referenceValueIndexes
        self.valueFormatter = valueFormatter
        super.init(frame: .zero)
        setup()
    }

    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
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

        if valueSlider.frame != previousValueSliderFrame {
            setNeedsUpdateConstraints()
        }
        previousValueSliderFrame = valueSlider.frame
    }

    override func updateConstraints() {
        super.updateConstraints()
        referenceValueViews.forEach({ view in
            let thumbRectForValue = thumbRect(for: view.value)
            view.midXConstraint?.constant = thumbRectForValue.midX
        })
    }
}

extension ValueSliderView {
    func setCurrentValue(_ value: ValueKind, animated: Bool) {
        guard let findResult = range.findClosestStep(for: value) else {
            return
        }

        valueSlider.setValueForSlider(findResult, animated: animated)
        updateActiveTrackRange()
        updateAccesibilityValues()
    }

    func thumbRect(for stepValue: ValueKind) -> CGRect {
        let bounds = valueSlider.bounds
        let trackRect = valueSlider.trackRect(forBounds: bounds)
        let translatedValue = valueSlider.translateValueToNormalizedRangeStartingFromZeroValue(value: stepValue)
        let thumbRect = valueSlider.thumbRect(forBounds: bounds, trackRect: trackRect, value: translatedValue)

        let convertedRect = valueSlider.convert(thumbRect, to: self)
        return convertedRect
    }
}

struct ValueSliderViewStyle {
    static let trackColor: UIColor = .sardine
    static let activeRangeTrackColor: UIColor = .primaryBlue
    static let sliderThumbImage: UIImage? = UIImage(named: .sliderThumb)
    static let activeSliderThumbImage: UIImage? = UIImage(named: .sliderThumbActive)
    static let trackHeight: CGFloat = 3.0
    static let activeRangeTrackHeight: CGFloat = 6.0
}

private extension ValueSliderView {
    func setup() {
        activeRangeTrackView.isHidden = true
        addSubview(trackView)
        addSubview(activeRangeTrackView)
        addSubview(valueSlider)
        addSubview(referenceValuesContainer)

        let referenceViewsConstraints = setupReferenceValueView()

        let activeRangeTrackViewLeadingAnchor = activeRangeTrackView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor)

        let activeRangeTrackViewTrailingAnchor = activeRangeTrackView.trailingAnchor.constraint(equalTo: trackView.trailingAnchor)
        activeRangeTrackViewTrailingAnchor.identifier = activeRangeTrackViewTrailingAnchorIdentifier

        NSLayoutConstraint.activate([
            valueSlider.topAnchor.constraint(equalTo: topAnchor),
            valueSlider.leadingAnchor.constraint(equalTo: leadingAnchor),
            valueSlider.trailingAnchor.constraint(equalTo: trailingAnchor),

            trackView.leadingAnchor.constraint(equalTo: valueSlider.leadingAnchor, constant: .verySmallSpacing),
            trackView.trailingAnchor.constraint(equalTo: valueSlider.trailingAnchor, constant: -.verySmallSpacing),
            trackView.centerYAnchor.constraint(equalTo: valueSlider.centerYAnchor),
            trackView.heightAnchor.constraint(equalToConstant: ValueSliderViewStyle.trackHeight),
            activeRangeTrackViewLeadingAnchor,
            activeRangeTrackViewTrailingAnchor,
            activeRangeTrackView.centerYAnchor.constraint(equalTo: valueSlider.centerYAnchor),
            activeRangeTrackView.heightAnchor.constraint(equalToConstant: ValueSliderViewStyle.activeRangeTrackHeight),

            referenceValuesContainer.topAnchor.constraint(equalTo: valueSlider.bottomAnchor, constant: .smallSpacing),
            referenceValuesContainer.leadingAnchor.constraint(equalTo: valueSlider.leadingAnchor),
            referenceValuesContainer.trailingAnchor.constraint(equalTo: valueSlider.trailingAnchor),
            referenceValuesContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
        ] + referenceViewsConstraints)

        accessibilityElements = [valueSlider]
        updateAccesibilityValues()
    }

    func setupReferenceValueView() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        referenceValueViews = referenceValueIndexes.map({ index in
            let referenceValue = range[index]
            return SliderReferenceValueView<ValueKind>(value: referenceValue, displayText: valueFormatter.title(for: referenceValue))
        })

        referenceValueViews.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            referenceValuesContainer.addSubview(view)

            let centerXConstraint = view.centerXAnchor.constraint(equalTo: referenceValuesContainer.leadingAnchor)

            constraints.append(contentsOf: [
                centerXConstraint,
                view.topAnchor.constraint(equalTo: referenceValuesContainer.topAnchor),
                view.bottomAnchor.constraint(equalTo: referenceValuesContainer.bottomAnchor),
            ])

            view.midXConstraint = centerXConstraint
        }
        return constraints
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

extension ValueSliderView: StepSliderDelegate {
    func stepSlider<StepValueKind>(_ stepSlider: StepSlider<StepValueKind>, didChangeValue value: Float) {
        updateActiveTrackRange()
        updateAccesibilityValues()
    }

    func stepSlider<StepValueKind>(_ stepSlider: StepSlider<StepValueKind>, didChangeRoundedStepValue value: StepValueKind) {
        guard let value = value as? ValueKind else {
            return
        }
        delegate?.valueViewControl(self, didChangeValue: value, didFinishSlideInteraction: false)
    }

    func stepSlider<StepValueKind>(_ stepSlider: StepSlider<StepValueKind>, didEndSlideInteraction value: StepValueKind) where StepValueKind: Comparable {
        guard let value = value as? ValueKind else {
            return
        }
        delegate?.valueViewControl(self, didChangeValue: value, didFinishSlideInteraction: true)
    }
}
