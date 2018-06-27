//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public final class RangeFilterView: UIControl {
    private lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = isValueCurrency ? .currency : .none
        formatter.currencySymbol = ""
        formatter.locale = Locale(identifier: "nb_NO")
        formatter.maximumFractionDigits = 0

        return formatter
    }()

    private lazy var numberInputView: RangeNumberInputView = {
        let inputFontSize = usesSmallNumberInputFont ? RangeNumberInputView.InputFontSize.small : RangeNumberInputView.InputFontSize.large
        let rangeNumberInputView = RangeNumberInputView(range: range, unit: unit, formatter: formatter, inputFontSize: inputFontSize, displaysUnitInNumberInput: displaysUnitInNumberInput)
        rangeNumberInputView.translatesAutoresizingMaskIntoConstraints = false
        rangeNumberInputView.addTarget(self, action: #selector(numberInputValueChanged(_:)), for: .valueChanged)

        return rangeNumberInputView
    }()

    private lazy var sliderInputView: RangeSliderView = {
        let rangeSliderView = RangeSliderView(range: range, additionalLowerBoundOffset: additionalLowerBoundOffset, additionalUpperBoundOffset: additionalUpperBoundOffset, steps: steps)
        rangeSliderView.translatesAutoresizingMaskIntoConstraints = false
        rangeSliderView.addTarget(self, action: #selector(sliderInputValueChanged(_:)), for: .valueChanged)
        return rangeSliderView
    }()

    private lazy var referenceValuesContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = false
        return view
    }()

    public var generatesHapticFeedbackOnSliderValueChange = true {
        didSet {
            sliderInputView.generatesHapticFeedbackOnValueChange = generatesHapticFeedbackOnSliderValueChange
        }
    }

    public var accessibilityValueSuffix: String? {
        didSet {
            sliderInputView.accessibilityValueSuffix = accessibilityValueSuffix
            numberInputView.accessibilityValueSuffix = accessibilityValueSuffix
        }
    }

    private var _accessibilitySteps: Int?
    public var sliderAccessibilitySteps: Int? {
        get {
            guard let accessibilitySteps = _accessibilitySteps else {
                return steps
            }

            return accessibilitySteps
        }
        set {
            _accessibilitySteps = newValue
            sliderInputView.accessibilitySteps = newValue ?? steps
        }
    }

    private enum InputValue {
        case low, high
    }

    private var inputValues = [InputValue: RangeValue]()
    private var referenceValueViews = [ReferenceValueView]()

    public typealias RangeValue = Int
    public typealias InputRange = ClosedRange<RangeValue>
    let range: InputRange
    let additionalLowerBoundOffset: RangeValue
    let additionalUpperBoundOffset: RangeValue
    let effectiveRange: InputRange
    let steps: Int
    let unit: String
    let isValueCurrency: Bool
    let referenceValues: [RangeValue]
    let usesSmallNumberInputFont: Bool
    let displaysUnitInNumberInput: Bool

    public init(range: InputRange, additionalLowerBoundOffset: RangeValue = 0, additionalUpperBoundOffset: RangeValue = 0, steps: Int, unit: String, isValueCurrency: Bool, referenceValues: [RangeValue], usesSmallNumberInputFont: Bool = false, displaysUnitInNumberInput: Bool = true) {
        self.range = range
        self.additionalLowerBoundOffset = additionalLowerBoundOffset
        self.additionalUpperBoundOffset = additionalUpperBoundOffset
        effectiveRange = RangeFilterView.effectiveRange(from: range, with: additionalLowerBoundOffset, and: additionalUpperBoundOffset)
        self.steps = steps
        self.unit = unit
        self.isValueCurrency = isValueCurrency
        self.referenceValues = referenceValues
        self.usesSmallNumberInputFont = usesSmallNumberInputFont
        self.displaysUnitInNumberInput = displaysUnitInNumberInput
        super.init(frame: .zero)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard self.point(inside: point, with: event) else {
            if numberInputView.isFirstResponder {
                _ = numberInputView.resignFirstResponder()
            }

            return nil
        }

        for subview in subviews {
            let convertedPoint = subview.convert(point, from: self)
            if let hitView = subview.hitTest(convertedPoint, with: event) {
                return hitView
            }
        }

        return nil
    }

    public override var accessibilityFrame: CGRect {
        didSet {
            sliderInputView.accessibilityFrame = accessibilityFrame
        }
    }

    public override func layoutSubviews() {
        referenceValueViews.forEach({ view in
            let thumbRectForValue = sliderInputView.thumbRect(for: view.value)
            let leadingConstant = thumbRectForValue.midX - (view.frame.width / 2)
            view.leadingConstraint?.constant = leadingConstant
        })

        if shouldForceSmallFontSizeForNumberInput() {
            numberInputView.forceSmallInputFontSize()
        }
    }

//    public override func setSelectionValue(_ selectionValue: FilterSelectionValue) {
//        guard case let FilterSelectionValue.rangeSelection(lowValue, highValue) = selectionValue else {
//            return
//        }
//
//        if let selectedLowValue = lowValue {
//            setLowValue(selectedLowValue, animated: false)
//        }
//
//        if let selectedHighValue = highValue {
//            setHighValue(selectedHighValue, animated: false)
//        }
//    }
}

extension RangeFilterView: RangeControl {
    public var lowValue: RangeValue? {
        return inputValues[.low]
    }

    public var highValue: RangeValue? {
        return inputValues[.high]
    }

    public func setLowValue(_ value: RangeValue, animated: Bool) {
        let lowValue = (value < range.lowerBound) ? effectiveRange.lowerBound : value
        updateNumberInput(for: .low, with: lowValue)
        updateSliderLowValue(with: lowValue)
        inputValues[.low] = lowValue
    }

    public func setHighValue(_ value: RangeValue, animated: Bool) {
        let highValue = (value > range.upperBound) ? effectiveRange.upperBound : value
        updateNumberInput(for: .high, with: highValue)
        updateSliderHighValue(with: highValue)
        inputValues[.high] = highValue
    }
}

private extension RangeFilterView {
    func setup() {
        addSubview(numberInputView)
        addSubview(sliderInputView)
        addSubview(referenceValuesContainer)

        NSLayoutConstraint.activate([
            numberInputView.topAnchor.constraint(equalTo: topAnchor),
            numberInputView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: .mediumSpacing),
            numberInputView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -.mediumSpacing),
            numberInputView.centerXAnchor.constraint(equalTo: centerXAnchor),

            sliderInputView.topAnchor.constraint(equalTo: numberInputView.bottomAnchor, constant: 50),
            sliderInputView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumLargeSpacing),
            sliderInputView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.mediumLargeSpacing),

            referenceValuesContainer.topAnchor.constraint(equalTo: sliderInputView.bottomAnchor, constant: .smallSpacing),
            referenceValuesContainer.leadingAnchor.constraint(equalTo: sliderInputView.leadingAnchor),
            referenceValuesContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            referenceValuesContainer.trailingAnchor.constraint(equalTo: sliderInputView.trailingAnchor),
        ])

        referenceValueViews = referenceValues.map({ ReferenceValueView(value: $0, unit: unit, formatter: formatter) })

        referenceValueViews.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            referenceValuesContainer.addSubview(view)

            let leadingConstraint = view.leadingAnchor.constraint(equalTo: referenceValuesContainer.leadingAnchor)

            NSLayoutConstraint.activate([
                leadingConstraint,
                view.topAnchor.constraint(equalTo: referenceValuesContainer.topAnchor),
                view.bottomAnchor.constraint(equalTo: referenceValuesContainer.bottomAnchor),
            ])

            view.leadingConstraint = leadingConstraint
        }
    }

    @objc func numberInputValueChanged(_ sender: RangeNumberInputView) {
        if let lowValue = sender.lowValue {
            updateSliderLowValue(with: lowValue)
            numberInputView.setLowValueHint(text: "")
            inputValues[.low] = lowValue
        }

        if let highValue = sender.highValue {
            updateSliderHighValue(with: highValue)
            numberInputView.setHighValueHint(text: "")
            inputValues[.high] = highValue
        }

        sendActions(for: .valueChanged)
    }

    @objc func sliderInputValueChanged(_ sender: RangeSliderView) {
        if let lowValue = sender.lowValue {
            updateNumberInput(for: .low, with: lowValue)
            inputValues[.low] = lowValue
        }

        if let highValue = sender.highValue {
            inputValues[.high] = highValue
            updateNumberInput(for: .high, with: highValue)
        }

        sendActions(for: .valueChanged)
    }

    func updateSliderLowValue(with value: RangeValue) {
        let isValueLowerThanRangeLowerBound = value < range.lowerBound
        let newValue = isValueLowerThanRangeLowerBound ? effectiveRange.lowerBound : value
        sliderInputView.setLowValue(newValue, animated: false)
    }

    func updateSliderHighValue(with value: RangeValue) {
        let isValueHigherThanRangeUpperBound = value > range.upperBound
        let newValue = isValueHigherThanRangeUpperBound ? effectiveRange.upperBound : value
        sliderInputView.setHighValue(newValue, animated: false)
    }

    private func updateNumberInput(for inputValue: InputValue, with value: RangeValue) {
        let isValueLowerThanRangeLowerBound = value < range.lowerBound
        let isValueIsHigherThaRangeUpperBound = value > range.upperBound
        let newValue: RangeValue
        let hintText: String

        if isValueLowerThanRangeLowerBound {
            newValue = range.lowerBound
            hintText = (value == effectiveRange.lowerBound) ? "Under" : ""
        } else if isValueIsHigherThaRangeUpperBound {
            newValue = range.upperBound
            hintText = (value == effectiveRange.upperBound) ? "Over" : ""
        } else {
            newValue = value
            hintText = ""
        }

        switch inputValue {
        case .low:
            numberInputView.setLowValueHint(text: hintText)
            numberInputView.setLowValue(newValue, animated: false)
        case .high:
            numberInputView.setHighValue(newValue, animated: false)
            numberInputView.setHighValueHint(text: hintText)
        }
    }

    func shouldForceSmallFontSizeForNumberInput() -> Bool {
        let iphone6ScreenWidth: CGFloat = 375

        return frame.width < iphone6ScreenWidth
    }

    static func effectiveRange(from range: InputRange, with lowerBoundOffset: RangeValue, and upperBoundOffset: RangeValue) -> InputRange {
        let newLowerBound = range.lowerBound - lowerBoundOffset
        let newUpperBound = range.upperBound + upperBoundOffset
        return InputRange(newLowerBound ... newUpperBound)
    }
}

private final class ReferenceValueView: UIView {
    lazy var indicatorView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .sardine
        view.layer.cornerRadius = 2.0
        return view
    }()

    weak var leadingConstraint: NSLayoutConstraint?

    lazy var referenceLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: FontType.light.rawValue, size: 12)
        label.textColor = .licorice
        label.textAlignment = .center

        return label
    }()

    let value: RangeFilterView.RangeValue
    let unit: String
    let formatter: NumberFormatter

    init(value: RangeFilterView.RangeValue, unit: String, formatter: NumberFormatter) {
        self.value = value
        self.unit = unit
        self.formatter = formatter
        super.init(frame: .zero)

        setup()
    }

    func setup() {
        referenceLabel.text = formatter.string(from: NSNumber(value: value))?.appending(" \(unit)")

        addSubview(indicatorView)
        addSubview(referenceLabel)

        NSLayoutConstraint.activate([
            indicatorView.topAnchor.constraint(equalTo: topAnchor),
            indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicatorView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            indicatorView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            indicatorView.widthAnchor.constraint(equalToConstant: 4),
            indicatorView.heightAnchor.constraint(equalToConstant: 4),

            referenceLabel.topAnchor.constraint(equalTo: indicatorView.bottomAnchor, constant: .mediumSpacing),
            referenceLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            referenceLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            referenceLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
