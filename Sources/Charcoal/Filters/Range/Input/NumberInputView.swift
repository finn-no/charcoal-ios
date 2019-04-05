//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol NumberInputViewDelegate: AnyObject {
    func numberInputViewDidBeginEditing(_ view: NumberInputView)
    func numberInputViewDidTapInside(_ view: NumberInputView)
    func numberInputView(_ view: NumberInputView, didChangeValue value: Int)
}

final class NumberInputView: UIView {
    weak var delegate: NumberInputViewDelegate?

    private let defaultValue: Int
    private let unit: FilterUnit
    private var fontSize: NumberInputFontSize
    private let formatter: RangeFilterValueFormatter
    private let lowValueInputDecorationViewConstraintIdentifier = "lowValueInputDecorationViewConstraintIdentifier"

    // MARK: - Views

    private lazy var textField: UITextField = {
        let textField = UITextField(withAutoLayout: true)
        textField.textColor = Style.textColor
        textField.font = Style.normalFont(size: fontSize)
        textField.keyboardType = .numberPad
        textField.textAlignment = .right
        textField.delegate = self
        return textField
    }()

    private lazy var unitLabel: UILabel = {
        let label = UILabel(withAutoLayout: true)
        label.textColor = Style.textColor
        label.font = Style.normalFont(size: fontSize)
        label.isUserInteractionEnabled = true
        label.isAccessibilityElement = false
        label.addGestureRecognizer(makeGestureRecognizer())
        return label
    }()

    private lazy var hintLabel: UILabel = {
        let label = UILabel(withAutoLayout: true)
        label.text = unit.lowerBoundText
        label.font = Style.hintNormalFont
        label.textColor = Style.textColor
        label.isAccessibilityElement = false
        return label
    }()

    private lazy var decorationView: UIView = {
        let view = UIView(withAutoLayout: true)
        view.backgroundColor = Style.decorationViewColor
        view.addGestureRecognizer(makeGestureRecognizer())
        return view
    }()

    var textFieldAccessibilityLabel: String? {
        get {
            return textField.accessibilityLabel
        }
        set {
            textField.accessibilityLabel = newValue
        }
    }

    // MARK: - Init

    init(defaultValue: Int, unit: FilterUnit, fontSize: NumberInputFontSize = .large) {
        self.defaultValue = defaultValue
        self.unit = unit
        self.fontSize = fontSize
        formatter = RangeFilterValueFormatter(unit: unit)
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override var isFirstResponder: Bool {
        return textField.isFirstResponder
    }

    override func resignFirstResponder() -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }

        return super.resignFirstResponder()
    }

    // MARK: - API

    func setValue(_ value: Int) {
        textField.text = formatter.string(from: value)
        textField.accessibilityValue = formatter.accessibilityValue(for: value)
    }

    func setValueHint(text: String) {
        hintLabel.text = text
    }

    func setValid(_ valid: Bool) {
        let textColor = valid ? Style.textColor : Style.errorTextColor
        textField.textColor = textColor
        unitLabel.textColor = textColor
    }

    func setActive(_ active: Bool) {
        let font: UIFont? = active ? Style.activeFont(size: fontSize) : Style.normalFont(size: fontSize)
        let outOfRangeBoundsFont = active ? Style.hintActiveFont : Style.hintNormalFont
        let decorationViewColor: UIColor = active ? Style.decorationViewActiveColor : Style.decorationViewColor

        textField.font = font
        unitLabel.attributedText = attributedUnitText(withFont: textField.font, from: unit)
        hintLabel.font = outOfRangeBoundsFont

        let constraint = decorationView.constraint(withIdentifier: lowValueInputDecorationViewConstraintIdentifier)
        constraint?.constant = active ? Style.decorationViewActiveHeight : Style.decorationViewHeight

        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.decorationView.backgroundColor = decorationViewColor
            self?.decorationView.layer.cornerRadius = active ? Style.decorationViewActiveCornerRadius : 0.0
            self?.decorationView.layoutIfNeeded()
        }

        if active {
            textField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
    }

    func forceSmallInputFontSize() {
        fontSize = .small
        textField.font = textField.isFirstResponder ? Style.activeFont(size: fontSize) : Style.normalFont(size: fontSize)
        unitLabel.font = textField.font
    }

    func setInputAccessoryView(previousView: NumberInputView? = nil, nextView: NumberInputView? = nil) {
        textField.inputAccessoryView = UIToolbar(
            target: self,
            previousTextField: previousView?.textField,
            nextTextField: nextView?.textField
        )
    }

    func setPreviousInputView(_ rangeInputView: NumberInputView?) {
        if let rangeInputView = rangeInputView {
            textField.inputAccessoryView = UIToolbar(target: self, previousTextField: rangeInputView.textField)
        } else {
            textField.inputAccessoryView = nil
        }
    }

    // MARK: - Setup

    private func setup() {
        let valueText = formatter.string(from: defaultValue)

        textField.text = valueText
        textField.accessibilityValue = formatter.accessibilityValue(for: defaultValue)
        unitLabel.attributedText = attributedUnitText(withFont: Style.normalFont(size: fontSize), from: unit)

        addSubview(hintLabel)
        addSubview(textField)
        addSubview(unitLabel)
        addSubview(decorationView)

        let lowValueInputDecorationViewConstraint = decorationView.heightAnchor.constraint(equalToConstant: Style.decorationViewHeight)
        lowValueInputDecorationViewConstraint.identifier = lowValueInputDecorationViewConstraintIdentifier

        NSLayoutConstraint.activate([
            hintLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            hintLabel.centerXAnchor.constraint(equalTo: decorationView.centerXAnchor),
            hintLabel.bottomAnchor.constraint(equalTo: textField.topAnchor),

            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.mediumSpacing),

            unitLabel.topAnchor.constraint(equalTo: textField.topAnchor),
            unitLabel.leadingAnchor.constraint(equalTo: textField.trailingAnchor),
            unitLabel.bottomAnchor.constraint(equalTo: textField.bottomAnchor),
            unitLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            decorationView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            decorationView.trailingAnchor.constraint(equalTo: unitLabel.trailingAnchor),
            decorationView.bottomAnchor.constraint(equalTo: bottomAnchor),
            lowValueInputDecorationViewConstraint,
        ])

        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        unitLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }

    // MARK: - Helpers

    private func attributedUnitText(withFont font: UIFont?, from unit: FilterUnit) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .justified
        style.firstLineHeadIndent = .mediumSpacing
        style.headIndent = .mediumSpacing
        style.tailIndent = -.mediumSpacing
        style.lineBreakMode = .byCharWrapping

        let attributes = [
            NSAttributedString.Key.font: font ?? UIFont.systemFont(ofSize: fontSize.rawValue),
            NSAttributedString.Key.paragraphStyle: style,
        ]

        return NSAttributedString(string: unit.value, attributes: attributes)
    }

    private func makeGestureRecognizer() -> UITapGestureRecognizer {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.addTarget(self, action: #selector(handleTapGesture(_:)))
        return tapGestureRecognizer
    }

    @objc private func handleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        delegate?.numberInputViewDidTapInside(self)
    }
}

// MARK: - UITextFieldDelegate

extension NumberInputView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.numberInputViewDidBeginEditing(self)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        setActive(false)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var text = textField.text ?? ""

        guard let stringRange = Range<String.Index>(range, in: text) else {
            return false
        }

        text.replaceSubrange(stringRange, with: string)
        text.removeWhitespaces()

        if text.isEmpty {
            text = "\(defaultValue)"
        }

        guard let newValue = Int(text) else {
            return false
        }

        textField.text = formatter.string(from: newValue)
        textField.accessibilityValue = formatter.accessibilityValue(for: newValue)

        delegate?.numberInputView(self, didChangeValue: newValue)

        return false
    }
}

// MARK: - Styles

private struct Style {
    static let textColor: UIColor = .licorice
    static let errorTextColor: UIColor = .cherry
    static let hintNormalFont: UIFont? = UIFont(name: FontType.light.rawValue, size: 16)
    static let hintActiveFont: UIFont? = UIFont(name: FontType.medium.rawValue, size: 16)
    static let decorationViewColor: UIColor = .stone
    static let decorationViewActiveColor: UIColor = .primaryBlue
    static let decorationViewHeight: CGFloat = 1.0
    static let decorationViewActiveHeight: CGFloat = 3.0
    static let decorationViewActiveCornerRadius = decorationViewActiveHeight / 2

    static func normalFont(size: NumberInputFontSize) -> UIFont? {
        return UIFont(name: FontType.light.rawValue, size: size.rawValue)
    }

    static func activeFont(size: NumberInputFontSize) -> UIFont? {
        return UIFont(name: FontType.bold.rawValue, size: size.rawValue)
    }
}

// MARK: - Private extensions

private extension UIView {
    func constraint(withIdentifier identifier: String) -> NSLayoutConstraint? {
        return constraints.first(where: { $0.identifier == identifier })
    }
}

private extension String {
    mutating func removeWhitespaces() {
        let components = self.components(separatedBy: .whitespaces)
        self = components.joined(separator: "")
    }
}

private extension UIToolbar {
    convenience init(target: UIView, previousTextField: UITextField? = nil, nextTextField: UITextField? = nil) {
        self.init()

        let items: [RangeToolbarItem] = [
            .arrow(imageAsset: .arrowLeft, target: previousTextField),
            .fixedSpace(width: .mediumLargeSpacing),
            .arrow(imageAsset: .arrowRight, target: nextTextField),
            .flexibleSpace,
            .done(target: target),
        ]

        sizeToFit()
        setItems(items.map({ $0.buttonItem }), animated: false)
    }
}
