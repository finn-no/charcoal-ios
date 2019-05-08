//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol RangeNumberInputViewDelegate: AnyObject {
    func rangeNumberInputView(_ view: RangeNumberInputView, didChangeLowValue value: Int?)
    func rangeNumberInputView(_ view: RangeNumberInputView, didChangeHighValue value: Int?)
}

final class RangeNumberInputView: UIView {
    private enum InputGroup {
        case lowValue
        case highValue
    }

    weak var delegate: RangeNumberInputViewDelegate?
    var generatesHapticFeedbackOnValueChange = true

    private let minimumValue: Int
    private let maximumValue: Int
    private let unit: FilterUnit
    private var fontSize: NumberInputFontSize
    private var inputValues = [InputGroup: Int]()
    private var inputValidationStatus = [InputGroup: Bool]()

    // MARK: - Views

    private lazy var lowValueInputView: NumberInputView = {
        let view = NumberInputView(defaultValue: minimumValue, unit: unit, fontSize: fontSize)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textFieldAccessibilityLabel = "range.numberInput.lowValueAccessibilityLabel".localized()
        view.delegate = self
        return view
    }()

    private lazy var highValueInputView: NumberInputView = {
        let view = NumberInputView(defaultValue: minimumValue, unit: unit, fontSize: fontSize)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textFieldAccessibilityLabel = "range.numberInput.highValueAccessibilityLabel".localized()
        view.delegate = self
        return view
    }()

    private lazy var inputSeparatorView: UILabel = {
        let label = UILabel(withAutoLayout: true)
        label.text = "-"
        label.textColor = .licorice
        label.font = UIFont.body.withSize(fontSize.rawValue)
        label.isAccessibilityElement = false
        return label
    }()

    // MARK: - Init

    init(minimumValue: Int, maximumValue: Int, unit: FilterUnit, usesSmallNumberInputFont: Bool = false) {
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.unit = unit
        fontSize = usesSmallNumberInputFont ? .small : .large
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard self.point(inside: point, with: event) else {
            _ = resignFirstResponder()
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

    override var isFirstResponder: Bool {
        return lowValueInputView.isFirstResponder || highValueInputView.isFirstResponder
    }

    override func resignFirstResponder() -> Bool {
        if lowValueInputView.isFirstResponder {
            _ = lowValueInputView.resignFirstResponder()
        } else if highValueInputView.isFirstResponder {
            _ = highValueInputView.resignFirstResponder()
        }

        return super.resignFirstResponder()
    }

    // MARK: - API

    var lowValue: Int? {
        return inputValues[.lowValue]
    }

    var highValue: Int? {
        return inputValues[.highValue]
    }

    func setLowValue(_ value: Int, animated: Bool) {
        lowValueInputView.setValue(value)
        inputValues[.lowValue] = value == minimumValue ? nil : value
        validateInputs(activeInputGroup: .lowValue)
    }

    func setHighValue(_ value: Int, animated: Bool) {
        highValueInputView.setValue(value)
        inputValues[.highValue] = value == maximumValue ? nil : value
        validateInputs(activeInputGroup: .highValue)
    }

    func setLowValueHint(text: String) {
        lowValueInputView.setValueHint(text: text)
    }

    func setHighValueHint(text: String) {
        highValueInputView.setValueHint(text: text)
    }

    func forceSmallInputFontSize() {
        fontSize = .smallest
        inputSeparatorView.font = UIFont.body.withSize(fontSize.rawValue)
        lowValueInputView.fontSize = fontSize
        highValueInputView.fontSize = fontSize
    }

    // MARK: - Setup

    private func setup() {
        lowValueInputView.setInputAccessoryView(nextView: highValueInputView)
        highValueInputView.setInputAccessoryView(previousView: lowValueInputView)

        addSubview(lowValueInputView)
        addSubview(highValueInputView)
        addSubview(inputSeparatorView)

        NSLayoutConstraint.activate([
            lowValueInputView.topAnchor.constraint(equalTo: topAnchor, constant: .largeSpacing),
            lowValueInputView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.mediumSpacing),
            lowValueInputView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            lowValueInputView.trailingAnchor.constraint(equalTo: inputSeparatorView.leadingAnchor, constant: -.mediumSpacing),
            lowValueInputView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.6),

            highValueInputView.topAnchor.constraint(equalTo: topAnchor, constant: .largeSpacing),
            highValueInputView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.mediumSpacing),
            highValueInputView.leadingAnchor.constraint(equalTo: inputSeparatorView.trailingAnchor, constant: .mediumSpacing),
            highValueInputView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            highValueInputView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.6),

            inputSeparatorView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 20),
        ])
    }

    // MARK: - Validation

    private func validateInputs(activeInputGroup: InputGroup) {
        let inactiveInputGroup: InputGroup = activeInputGroup == .lowValue ? .highValue : .lowValue

        updateValidationStatus(for: activeInputGroup, isValid: isValidValue(for: activeInputGroup))
        updateValidationStatus(for: inactiveInputGroup, isValid: true)
    }

    private func updateValidationStatus(for inputGroup: InputGroup, isValid: Bool, generateHapticFeedback: Bool = false) {
        inputView(for: inputGroup).setValid(isValid)

        let isCurrentValueValid = inputValidationStatus[inputGroup] ?? true
        let useHaptics = generateHapticFeedback && generatesHapticFeedbackOnValueChange

        if !isValid, isCurrentValueValid, useHaptics {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }

        inputValidationStatus[inputGroup] = isValid
    }

    private func isValidValue(for inputGroup: InputGroup) -> Bool {
        guard let lowValue = lowValue, let highValue = highValue else {
            return true
        }

        switch inputGroup {
        case .highValue:
            return lowValue <= highValue
        case .lowValue:
            return highValue >= lowValue
        }
    }

    // MARK: - Helpers

    private func handleInteraction(with inputGroup: InputGroup) {
        let otherInputGroup: InputGroup = inputGroup == .lowValue ? .highValue : .lowValue

        inputView(for: otherInputGroup).setActive(false)
        inputView(for: inputGroup).setActive(true)
        validateInputs(activeInputGroup: lowValueInputView.isFirstResponder ? .lowValue : .highValue)
    }

    private func inputGroup(for view: NumberInputView) -> InputGroup {
        return view === lowValueInputView ? .lowValue : .highValue
    }

    private func inputView(for inputGroup: InputGroup) -> NumberInputView {
        return inputGroup == .lowValue ? lowValueInputView : highValueInputView
    }
}

// MARK: - NumberInputViewDelegate

extension RangeNumberInputView: NumberInputViewDelegate {
    func numberInputViewDidBeginEditing(_ view: NumberInputView) {
        handleInteraction(with: inputGroup(for: view))
    }

    func numberInputViewDidTapInside(_ view: NumberInputView) {
        handleInteraction(with: inputGroup(for: view))
    }

    func numberInputView(_ view: NumberInputView, didChangeValue value: Int?) {
        let inputGroup = self.inputGroup(for: view)

        inputValues[inputGroup] = value
        updateValidationStatus(for: inputGroup, isValid: isValidValue(for: inputGroup), generateHapticFeedback: true)

        switch inputGroup {
        case .lowValue:
            delegate?.rangeNumberInputView(self, didChangeLowValue: value)
        case .highValue:
            delegate?.rangeNumberInputView(self, didChangeHighValue: value)
        }
    }
}
