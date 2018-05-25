//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public final class RangeNumberInputView: UIControl {
    public static let minimumViewHeight: CGFloat = 58.0

    private lazy var lowValueInputTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.textColor = RangeNumberInputView.Style.textColor
        textField.font = RangeNumberInputView.Style.normalFont
        textField.keyboardType = .numberPad
        textField.textAlignment = .right
//        textField.clearsOnInsertion = true
//        textField.clearsOnBeginEditing = true

        return textField
    }()

    private lazy var lowValueInputUnitLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = unit
        label.textColor = RangeNumberInputView.Style.textColor
        label.font = RangeNumberInputView.Style.normalFont
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapGestureRecognizer)

        return label
    }()

    private lazy var inputSeparatorView: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "-"
        label.textColor = RangeNumberInputView.Style.textColor
        label.font = RangeNumberInputView.Style.normalFont

        return label
    }()

    private lazy var highValueInputTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = RangeNumberInputView.Style.textColor
        textField.font = RangeNumberInputView.Style.normalFont
        textField.keyboardType = .numberPad
        textField.textAlignment = .right
//        textField.clearsOnInsertion = true
//        textField.clearsOnBeginEditing = true

        return textField
    }()

    private lazy var highValueInputUnitLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = unit
        label.textColor = RangeNumberInputView.Style.textColor
        label.font = RangeNumberInputView.Style.normalFont
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapGestureRecognizer)

        return label
    }()

    private lazy var lowValueInputDecorationView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Style.decorationViewColor
        view.addGestureRecognizer(tapGestureRecognizer)

        return view
    }()

    private lazy var highValueInputDecorationView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Style.decorationViewColor
        view.addGestureRecognizer(tapGestureRecognizer)

        return view
    }()

    private var tapGestureRecognizer: UITapGestureRecognizer {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.addTarget(self, action: #selector(handleTapGesture(_:)))

        return tapGestureRecognizer
    }

    private lazy var inputGroupMap: [UIView: InputGroup] = {
        return [
            lowValueInputTextField: .lowValue,
            lowValueInputUnitLabel: .lowValue,
            lowValueInputDecorationView: .lowValue,
            highValueInputTextField: .highValue,
            highValueInputUnitLabel: .highValue,
            highValueInputDecorationView: .highValue,
        ]
    }()

    private let lowValueInputDecorationViewConstraintIdentifier = "lowValueInputDecorationViewConstraintIdentifier"
    private let highValueInputDecorationViewConstraintIdentifier = "highValueInputDecorationViewConstraintIdentifier"
    private var inputValues = [InputGroup: RangeValue]()

    public typealias RangeValue = Int
    public typealias InputRange = ClosedRange<RangeValue>
    let range: InputRange
    let unit: String

    public init(range: InputRange, unit: String) {
        self.range = range
        self.unit = unit
        super.init(frame: .zero)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension RangeNumberInputView {
    var lowValue: RangeValue? {
        guard let lowInputValue = inputValues[.lowValue] else {
            return nil
        }

        guard let highInputValue = inputValues[.highValue] else {
            return lowInputValue
        }

        return min(lowInputValue, highInputValue)
    }

    var highValue: RangeValue? {
        guard let highInputValue = inputValues[.highValue] else {
            return nil
        }

        guard let lowInputValue = inputValues[.lowValue] else {
            return highInputValue
        }

        return max(lowInputValue, highInputValue)
    }

    func setLowerValue(_ value: RangeValue, animated: Bool) {
        lowValueInputTextField.text = text(from: value)
        inputValues[.lowValue] = value
    }

    func setUpperValue(_ value: RangeValue, animated: Bool) {
        highValueInputTextField.text = text(from: value)
        inputValues[.highValue] = value
    }
}

extension RangeNumberInputView: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let inputGroup = inputGroupMap[textField] else {
            return
        }

        handleInteraction(with: inputGroup)
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        guard let inputGroup = inputGroupMap[textField] else {
            return
        }

        setInputGroup(inputGroup, active: false)
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        defer {
            sendActions(for: .valueChanged)
        }

        textField.text?.dropLeadingZeros()

        let existingString = (textField.text ?? "")
        var newString = (existingString + string)

        if string == "" {
            newString = String(newString.dropLast())
        }

        guard let inputGroup = inputGroupMap[textField] else {
            return false
        }

        guard let newValue = RangeValue(newString) else {
            let value = self.range.lowerBound
            textField.text = "\(value)"
            inputValues[inputGroup] = value
            return false
        }

        if newValue >= self.range.upperBound {
            let value = self.range.upperBound
            textField.text = "\(value)"
            inputValues[inputGroup] = value
            return false
        } else if newValue <= self.range.lowerBound {
            let value = self.range.lowerBound
            textField.text = "\(value)"
            inputValues[inputGroup] = value
            return false
        } else {
            inputValues[inputGroup] = newValue
        }

        return true
    }
}

private extension RangeNumberInputView {
    struct Style {
        static let textColor: UIColor = .licorice
        static let normalFont: UIFont? = UIFont(name: FontType.light.rawValue, size: 36)
        static let activeFont: UIFont? = UIFont(name: FontType.bold.rawValue, size: 36)
        static let decorationViewColor: UIColor = .stone
        static let decorationViewActiveColor: UIColor = .primaryBlue
        static let decorationViewHeight: CGFloat = 1.0
        static let decorationViewActiveHeight: CGFloat = 3.0
        static let decorationViewActiveCornerRadius = decorationViewActiveHeight / 2
    }

    enum InputGroup {
        case lowValue, highValue
    }

    func setup() {
        lowValueInputTextField.text = text(from: range.lowerBound)
        highValueInputTextField.text = text(from: range.lowerBound)

        addSubview(lowValueInputTextField)
        addSubview(lowValueInputUnitLabel)
        addSubview(inputSeparatorView)
        addSubview(highValueInputTextField)
        addSubview(highValueInputUnitLabel)
        addSubview(lowValueInputDecorationView)
        addSubview(highValueInputDecorationView)

        let lowValueInputDecorationViewConstraint = lowValueInputDecorationView.heightAnchor.constraint(equalToConstant: Style.decorationViewHeight)
        lowValueInputDecorationViewConstraint.identifier = lowValueInputDecorationViewConstraintIdentifier
        let highValueInputDecorationViewConstraint = highValueInputDecorationView.heightAnchor.constraint(equalToConstant: Style.decorationViewHeight)
        highValueInputDecorationViewConstraint.identifier = highValueInputDecorationViewConstraintIdentifier

        NSLayoutConstraint.activate([
            lowValueInputTextField.topAnchor.constraint(equalTo: topAnchor),
            lowValueInputTextField.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            lowValueInputTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.mediumSpacing),

            lowValueInputUnitLabel.topAnchor.constraint(equalTo: lowValueInputTextField.topAnchor),
            lowValueInputUnitLabel.leadingAnchor.constraint(equalTo: lowValueInputTextField.trailingAnchor, constant: .mediumSpacing),
            lowValueInputUnitLabel.bottomAnchor.constraint(equalTo: lowValueInputTextField.bottomAnchor),
            lowValueInputUnitLabel.trailingAnchor.constraint(equalTo: inputSeparatorView.leadingAnchor, constant: -.mediumSpacing),

            inputSeparatorView.topAnchor.constraint(equalTo: lowValueInputTextField.topAnchor),
            inputSeparatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            inputSeparatorView.bottomAnchor.constraint(equalTo: lowValueInputTextField.bottomAnchor),

            highValueInputTextField.topAnchor.constraint(equalTo: topAnchor),
            highValueInputTextField.leadingAnchor.constraint(equalTo: inputSeparatorView.trailingAnchor, constant: .mediumSpacing),
            highValueInputTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.mediumSpacing),

            highValueInputUnitLabel.topAnchor.constraint(equalTo: highValueInputTextField.topAnchor),
            highValueInputUnitLabel.leadingAnchor.constraint(equalTo: highValueInputTextField.trailingAnchor, constant: .mediumSpacing),
            highValueInputUnitLabel.bottomAnchor.constraint(equalTo: highValueInputTextField.bottomAnchor),
            highValueInputUnitLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),

            lowValueInputDecorationView.leadingAnchor.constraint(equalTo: lowValueInputTextField.leadingAnchor),
            lowValueInputDecorationView.trailingAnchor.constraint(equalTo: lowValueInputUnitLabel.trailingAnchor),
            lowValueInputDecorationView.bottomAnchor.constraint(equalTo: bottomAnchor),
            lowValueInputDecorationViewConstraint,

            highValueInputDecorationView.leadingAnchor.constraint(equalTo: highValueInputTextField.leadingAnchor),
            highValueInputDecorationView.trailingAnchor.constraint(equalTo: highValueInputUnitLabel.trailingAnchor),
            highValueInputDecorationView.bottomAnchor.constraint(equalTo: bottomAnchor),
            highValueInputDecorationViewConstraint,
        ])
    }

    func text(from value: RangeValue) -> String {
        return "\(value)"
    }

    @objc func handleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let view = gestureRecognizer.view, let inputGroup = inputGroupMap[view] else {
            return
        }

        handleInteraction(with: inputGroup)
    }

    func handleInteraction(with inputGroup: InputGroup) {
        let otherInputGroup: InputGroup = inputGroup == .lowValue ? .highValue : .lowValue
        setInputGroup(otherInputGroup, active: false)
        setInputGroup(inputGroup, active: true)
    }

    func setInputGroup(_ inputGroup: InputGroup, active: Bool) {
        let font: UIFont? = active ? Style.activeFont : Style.normalFont
        let decorationViewColor: UIColor = active ? Style.decorationViewActiveColor : Style.decorationViewColor

        switch inputGroup {
        case .lowValue:
            lowValueInputTextField.font = font
            lowValueInputUnitLabel.font = font
            let constraint = lowValueInputDecorationView.constraint(withIdentifier: lowValueInputDecorationViewConstraintIdentifier)
            constraint?.constant = active ? Style.decorationViewActiveHeight : Style.decorationViewHeight
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.lowValueInputDecorationView.backgroundColor = decorationViewColor
                self?.lowValueInputDecorationView.layer.cornerRadius = active ? Style.decorationViewActiveCornerRadius : 0.0
                self?.lowValueInputDecorationView.layoutIfNeeded()
            }
        case .highValue:
            highValueInputTextField.font = font
            highValueInputUnitLabel.font = font
            let constraint = highValueInputDecorationView.constraint(withIdentifier: highValueInputDecorationViewConstraintIdentifier)
            constraint?.constant = active ? Style.decorationViewActiveHeight : Style.decorationViewHeight
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.highValueInputDecorationView.backgroundColor = decorationViewColor
                self?.highValueInputDecorationView.layer.cornerRadius = active ? Style.decorationViewActiveCornerRadius : 0.0
                self?.highValueInputDecorationView.layoutIfNeeded()
            }
        }

        let inputGroupTextField = inputGroup == .lowValue ? lowValueInputTextField : highValueInputTextField
        if active {
            inputGroupTextField.becomeFirstResponder()
        } else {
            inputGroupTextField.resignFirstResponder()
        }
    }
}

private extension UIView {
    func constraint(withIdentifier identifier: String) -> NSLayoutConstraint? {
        return constraints.first(where: { $0.identifier == identifier })
    }
}

private extension String {
    mutating func dropLeadingZeros() {
        if let firstChararcter = self.first, let firstNumber = Int(String(firstChararcter)), firstNumber == 0 {
            self = String(dropFirst())
            dropLeadingZeros()
        }
    }
}
