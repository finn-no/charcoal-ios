//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol RangeSliderViewDelegate: AnyObject {
    func rangeSliderView(_ rangeSliderView: RangeSliderView, didChangeLowStep: Step)
    func rangeSliderView(_ rangeSliderView: RangeSliderView, didChangeHighStep: Step)
}

final class RangeSliderView: UIControl {
    weak var delegate: RangeSliderViewDelegate?

    private static var visibleThumbWidth: CGFloat = 28
    private let filterConfig: RangeFilterConfiguration
    private let formatter: SliderValueFormatter
    private let activeRangeTrackViewLeadingAnchorIdentifier = "activeRangeTrackViewLeadingAnchorIdentifier"
    private let activeRangeTrackViewTrailingAnchorIdentifier = "activeRangeTrackViewTrailingAnchorIdentifier"

    private lazy var lowValueSlider = makeStepSlider()
    private lazy var highValueSlider = makeStepSlider()

    private lazy var lowSliderStep: Step = lowValueSlider.step
    private lazy var highSliderStep: Step = highValueSlider.step

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

    // MARK: - Init

    init(filterConfig: RangeFilterConfiguration, formatter: SliderValueFormatter) {
        self.filterConfig = filterConfig
        self.formatter = formatter
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

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
        let slider = StepSlider(
            numberOfSteps: filterConfig.values.count - 1,
            hasLeftOffset: filterConfig.hasLowerBoundOffset,
            hasRightOffset: filterConfig.hasUpperBoundOffset
        )

        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.delegate = self
        return slider
    }
}

// MARK: - Internal

extension RangeSliderView {
    func setLowStep(_ step: Step, animated: Bool) {
        lowSliderStep = step
        let step = highValueSlider.step < step ? highValueSlider.step : step

        lowValueSlider.setStep(step, animated: animated)
        updateActiveTrackRange()
        updateAccesibilityValues()
    }

    func setHighStep(_ step: Step, animated: Bool) {
        highSliderStep = step
        let step = lowValueSlider.step > step ? lowValueSlider.step : step

        highValueSlider.setStep(step, animated: animated)
        updateActiveTrackRange()
        updateAccesibilityValues()
    }

    func thumbRect(for value: Int) -> CGRect {
        let bounds = lowValueSlider.bounds
        let trackRect = lowValueSlider.trackRect(forBounds: bounds)
        let closestStep = filterConfig.values.closestStep(for: value)
        let translatedValue = lowValueSlider.value(from: closestStep)
        let thumbRect = lowValueSlider.thumbRect(forBounds: bounds, trackRect: trackRect, value: Float(translatedValue))
        let thumbRadius = RangeSliderView.visibleThumbWidth / 2 - 2
        let rectOffsetingInvisibleThumbPadding = thumbRect.offsetBy(dx: thumbRadius, dy: 0)

        return rectOffsetingInvisibleThumbPadding
    }
}

// MARK: - Private

extension RangeSliderView {
    private func setup() {
        lowValueSlider.setStep(.lowerBound, animated: false)
        highValueSlider.setStep(.upperBound, animated: false)

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

    private func updateActiveTrackRange() {
        if frame == .zero {
            return
        }

        let leadingConstant = lowValueSlider.currentThumbRect.midX
        let trailingConstant = highValueSlider.currentThumbRect.midX - highValueSlider.bounds.maxX
        let activeRangeTrackViewLeadingAnchor = constraints.filter { $0.identifier == activeRangeTrackViewLeadingAnchorIdentifier }.first
        let activeRangeTrackViewTrailingAnchor = constraints.filter { $0.identifier == activeRangeTrackViewTrailingAnchorIdentifier }.first

        activeRangeTrackViewLeadingAnchor?.constant = leadingConstant
        activeRangeTrackViewTrailingAnchor?.constant = trailingConstant

        activeRangeTrackView.layoutIfNeeded()
        activeRangeTrackView.isHidden = false
    }

    private func updateAccesibilityValues() {
        lowValueSlider.accessibilityLabel = "range.slider.lowValueAccessibilityLabel".localized()
        highValueSlider.accessibilityLabel = "range.slider.highValueAccessibilityLabel".localized()
    }
}

// MARK: - StepSliderDelegate

extension RangeSliderView: StepSliderDelegate {
    func stepSlider(_ stepSlider: StepSlider, didChangeValue value: Float) {
        updateActiveTrackRange()
        updateAccesibilityValues()
    }

    func stepSlider(_ stepSlider: StepSlider, canChangeToStep step: Step) -> Bool {
        if stepSlider == highValueSlider {
            return step >= lowValueSlider.step
        } else if stepSlider == lowValueSlider {
            return step <= highValueSlider.step
        } else {
            return true
        }
    }

    func stepSlider(_ stepSlider: StepSlider, didChangeStep step: Step) {
        if lowValueSlider.step == highValueSlider.step, generatesHapticFeedbackOnValueChange {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }

        handleStepUpdate(newStep: step, stepSlider: stepSlider)
    }

    func stepSlider(_ stepSlider: StepSlider, didEndSlideInteraction step: Step) {
        handleStepUpdate(newStep: step, stepSlider: stepSlider)
    }

    func stepSlider(_ stepSlider: StepSlider, accessibilityValueForStep step: Step) -> String {
        switch step {
        case .value:
            return filterConfig.value(for: step).map { formatter.accessibilityValue(for: $0) } ?? ""
        case .lowerBound:
            return filterConfig.unit.lowerBoundText + " \(filterConfig.minimumValue)"
        case .upperBound:
            return filterConfig.unit.upperBoundText + " \(filterConfig.maximumValue)"
        }
    }

    private func handleStepUpdate(newStep: Step, stepSlider: StepSlider) {
        if stepSlider == highValueSlider {
            highSliderStep = newStep
            setLowStep(lowSliderStep, animated: false)
            delegate?.rangeSliderView(self, didChangeHighStep: newStep)
        } else {
            lowSliderStep = newStep
            setHighStep(highSliderStep, animated: false)
            delegate?.rangeSliderView(self, didChangeLowStep: newStep)
        }
    }
}

// MARK: - Styles

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
