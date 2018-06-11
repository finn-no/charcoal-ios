//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

final class RangeNumberInputView: UIControl {
    private lazy var lowValueInputTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.textColor = RangeNumberInputView.Style.textColor
        textField.font = RangeNumberInputView.Style.normalFont
        textField.keyboardType = .numberPad
        textField.textAlignment = .right
        textField.accessibilityLabel = "range_number_input_view_low_value_textfield_accessibility_label".localized()

        return textField
    }()

    private lazy var lowValueInputUnitLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = unit
        label.textColor = RangeNumberInputView.Style.textColor
        label.font = RangeNumberInputView.Style.normalFont
        label.addGestureRecognizer(makeGestureRecognizer())
        label.isUserInteractionEnabled = true
        label.isAccessibilityElement = false
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
        textField.accessibilityLabel = "range_number_input_view_high_value_textfield_accessibility_label".localized()

        return textField
    }()

    private lazy var highValueInputUnitLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = unit
        label.textColor = RangeNumberInputView.Style.textColor
        label.font = RangeNumberInputView.Style.normalFont
        label.addGestureRecognizer(makeGestureRecognizer())
        label.isUserInteractionEnabled = true
        label.isAccessibilityElement = false

        return label
    }()

    private lazy var lowValueInputDecorationView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Style.decorationViewColor
        view.addGestureRecognizer(makeGestureRecognizer())

        return view
    }()

    private lazy var highValueInputDecorationView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Style.decorationViewColor
        view.addGestureRecognizer(makeGestureRecognizer())

        return view
    }()

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

    typealias RangeValue = Int
    typealias InputRange = ClosedRange<RangeValue>
    let range: InputRange
    let unit: String

    init(range: InputRange, unit: String) {
        self.range = range
        self.unit = unit
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

    var accessibilityValueSuffix: String? {
        didSet {
        }
    }

    override var isFirstResponder: Bool {
        return lowValueInputTextField.isFirstResponder || highValueInputTextField.isFirstResponder
    }

    override func resignFirstResponder() -> Bool {
        if lowValueInputTextField.isFirstResponder {
            lowValueInputTextField.resignFirstResponder()
        } else if highValueInputTextField.isFirstResponder {
            highValueInputTextField.resignFirstResponder()
        }

        return super.resignFirstResponder()
    }
}

extension RangeNumberInputView: RangeControl {
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

    func setLowValue(_ value: RangeValue, animated: Bool) {
        let valueText = text(from: value)
        lowValueInputTextField.text = valueText
        lowValueInputTextField.accessibilityValue = "\(valueText) \(accessibilityValueSuffix ?? "")"
        inputValues[.lowValue] = value
    }

    func setHighValue(_ value: RangeValue, animated: Bool) {
        let valueText = text(from: value)
        highValueInputTextField.text = valueText
        highValueInputTextField.accessibilityValue = "\(valueText) \(accessibilityValueSuffix ?? "")"
        inputValues[.highValue] = value
    }
}

extension RangeNumberInputView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let inputGroup = inputGroupMap[textField] else {
            return
        }

        handleInteraction(with: inputGroup)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let inputGroup = inputGroupMap[textField] else {
            return
        }

        setInputGroup(inputGroup, active: false)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        defer {
            sendActions(for: .valueChanged)
        }

        var text = textField.text ?? ""

        guard let stringRange = Range<String.Index>(range, in: text) else {
            return false
        }

        text.replaceSubrange(stringRange, with: string)

        if text.isEmpty {
            text = "\(self.range.lowerBound)"
        }

        guard let inputGroup = inputGroupMap[textField] else {
            return false
        }

        guard let newValue = RangeValue(text) else {
            inputValues[inputGroup] = nil
            return false
        }

        textField.text = "\(newValue)"
        textField.accessibilityValue = "\(newValue) \(accessibilityValueSuffix ?? "")"
        inputValues[inputGroup] = newValue

        if let font = RangeNumberInputView.Style.activeFont {
            let attributes = [NSAttributedStringKey.font: font]
            let maxTextFieldBounds = self.maxTextFieldBounds(for: inputGroup)
            let shouldAdjustsFontSizeToFitWidth = text.willFit(in: maxTextFieldBounds, attributes: attributes) == false

            if shouldAdjustsFontSizeToFitWidth {
                textField.adjustsFontSizeToFitWidth = true
                textField.minimumFontSize = Style.minimumFontSize
            } else {
                textField.minimumFontSize = Style.normalFontSize
            }
        }

        return false
    }
}

private extension RangeNumberInputView {
    struct Style {
        static let textColor: UIColor = .licorice
        static let minimumFontSize: CGFloat = 22
        static let normalFontSize: CGFloat = 36
        static let normalFont: UIFont? = UIFont(name: FontType.light.rawValue, size: normalFontSize)
        static let activeFont: UIFont? = UIFont(name: FontType.bold.rawValue, size: normalFontSize)
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
        let valueText = text(from: range.lowerBound)
        lowValueInputTextField.text = valueText
        highValueInputTextField.text = valueText
        lowValueInputTextField.accessibilityValue = "\(valueText) \(accessibilityValueSuffix ?? "")"
        highValueInputTextField.accessibilityValue = "\(valueText) \(accessibilityValueSuffix ?? "")"

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

            lowValueInputDecorationView.leadingAnchor.constraint(equalTo: lowValueInputTextField.leadingAnchor, constant: 4),
            lowValueInputDecorationView.trailingAnchor.constraint(equalTo: lowValueInputUnitLabel.trailingAnchor),
            lowValueInputDecorationView.bottomAnchor.constraint(equalTo: bottomAnchor),
            lowValueInputDecorationViewConstraint,

            highValueInputDecorationView.leadingAnchor.constraint(equalTo: highValueInputTextField.leadingAnchor, constant: 4),
            highValueInputDecorationView.trailingAnchor.constraint(equalTo: highValueInputUnitLabel.trailingAnchor),
            highValueInputDecorationView.bottomAnchor.constraint(equalTo: bottomAnchor),
            highValueInputDecorationViewConstraint,
        ])

        lowValueInputUnitLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        highValueInputUnitLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
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

    func makeGestureRecognizer() -> UITapGestureRecognizer {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.addTarget(self, action: #selector(handleTapGesture(_:)))

        return tapGestureRecognizer
    }

    func maxTextFieldBounds(for inputGroup: InputGroup) -> CGRect {
        let maxRect: CGRect
        switch inputGroup {
        case .lowValue:
            let currentFrame = lowValueInputTextField.frame
            let minX: CGFloat = 0
            let maxX = currentFrame.maxX
            let maxWidth = maxX - minX

            maxRect = CGRect(x: 0, y: 0, width: maxWidth, height: currentFrame.height)
        case .highValue:
            let currentFrame = highValueInputTextField.frame
            let minX = currentFrame.minX
            let maxX = frame.width - (highValueInputUnitLabel.frame.width + .mediumSpacing)
            let maxWidth = maxX - minX

            maxRect = CGRect(x: 0, y: 0, width: maxWidth, height: currentFrame.height)
        }

        return maxRect
    }
}

private extension UIView {
    func constraint(withIdentifier identifier: String) -> NSLayoutConstraint? {
        return constraints.first(where: { $0.identifier == identifier })
    }
}

private extension String {
    func willFit(in rect: CGRect, attributes: [NSAttributedStringKey: Any]) -> Bool {
        let attributedString = NSAttributedString(string: self, attributes: attributes)
        let constrainedSize = CGSize(width: 0, height: rect.size.height)
        let boundingRect = attributedString.boundingRect(with: constrainedSize, options: .usesLineFragmentOrigin, context: nil)

        return boundingRect.width <= rect.width
    }
}
