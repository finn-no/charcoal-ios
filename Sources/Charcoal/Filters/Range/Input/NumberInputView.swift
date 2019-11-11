//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol NumberInputViewDelegate: AnyObject {
    func numberInputViewDidBeginEditing(_ view: NumberInputView)
    func numberInputViewDidTapInside(_ view: NumberInputView)
    func numberInputView(_ view: NumberInputView, didChangeValue value: Int?)
}

final class NumberInputView: UIView {
    weak var delegate: NumberInputViewDelegate?

    private let defaultValue: Int
    private let unit: FilterUnit
    private let formatter: RangeFilterValueFormatter

    // MARK: - Views

    private lazy var textField: UITextField = {
        let textField = UITextField(withAutoLayout: true)
        textField.textColor = Style.textColor
        textField.font = Style.normalFont(size: fontSize)
        textField.adjustsFontForContentSizeCategory = true
        textField.keyboardType = .numberPad
        textField.textAlignment = .right
        textField.delegate = self
        return textField
    }()

    private lazy var unitLabel: UILabel = {
        let label = UILabel(withAutoLayout: true)
        label.attributedText = attributedUnitText(withFont: Style.normalFont(size: fontSize), from: unit)
        label.textColor = Style.textColor
        label.font = Style.normalFont(size: fontSize)
        label.adjustsFontForContentSizeCategory = true
        label.isUserInteractionEnabled = true
        label.isAccessibilityElement = false
        label.addGestureRecognizer(makeGestureRecognizer())
        return label
    }()

    private lazy var hintLabel: UILabel = {
        let label = UILabel(withAutoLayout: true)
        label.text = unit.lowerBoundText
        label.font = Style.hintNormalFont
        label.adjustsFontForContentSizeCategory = true
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

    private lazy var decorationViewHeightConstraint = decorationView.heightAnchor.constraint(
        equalToConstant: Style.decorationViewHeight
    )

    // MARK: - Internal properties

    var fontSize: NumberInputFontSize {
        didSet {
            textField.font = textField.isFirstResponder ? Style.activeFont(size: fontSize) : Style.normalFont(size: fontSize)
            unitLabel.font = textField.font
        }
    }

    var textFieldAccessibilityLabel: String? {
        get { return textField.accessibilityLabel }
        set { textField.accessibilityLabel = newValue }
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
        decorationViewHeightConstraint.constant = active ? Style.decorationViewActiveHeight : Style.decorationViewHeight

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

    func setInputAccessoryView(previousView: NumberInputView? = nil, nextView: NumberInputView? = nil) {
        textField.inputAccessoryView = UIToolbar(
            target: self,
            previousTextField: previousView?.textField,
            nextTextField: nextView?.textField
        )
    }

    // MARK: - Setup

    private func setup() {
        setValue(defaultValue)

        addSubview(hintLabel)
        addSubview(textField)
        addSubview(unitLabel)
        addSubview(decorationView)

        NSLayoutConstraint.activate([
            hintLabel.topAnchor.constraint(equalTo: topAnchor),
            hintLabel.centerXAnchor.constraint(equalTo: decorationView.centerXAnchor),

            textField.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.mediumSpacing),

            unitLabel.topAnchor.constraint(equalTo: textField.topAnchor),
            unitLabel.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: .mediumSpacing),
            unitLabel.bottomAnchor.constraint(equalTo: textField.bottomAnchor),
            unitLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            decorationView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            decorationView.trailingAnchor.constraint(equalTo: unitLabel.trailingAnchor),
            decorationView.bottomAnchor.constraint(equalTo: bottomAnchor),
            decorationViewHeightConstraint,
        ])

        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        unitLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }

    // MARK: - Helpers

    private func attributedUnitText(withFont font: UIFont?, from unit: FilterUnit) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .justified
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

        guard let stringRange = text.replacementRangeNotConsideringWhitespaces(from: range, replacementString: string) else {
            return false
        }

        let oldText = text
        let range = NSRange(stringRange, in: text)

        text.replaceSubrange(stringRange, with: string)
        text.removeWhitespaces()

        if text.isEmpty {
            textField.text = text
            textField.accessibilityValue = "noValue".localized()
            delegate?.numberInputView(self, didChangeValue: nil)
        } else if let newValue = Int(text) {
            textField.text = formatter.string(from: newValue)
            textField.accessibilityValue = formatter.accessibilityValue(for: newValue)
            delegate?.numberInputView(self, didChangeValue: newValue)
        }

        textField.updateCursorAfterReplacement(in: range, with: string, oldText: oldText)

        return false
    }
}

// MARK: - Styles

private struct Style {
    static let textColor: UIColor = .textPrimary
    static let errorTextColor: UIColor = .textCritical
    static let hintNormalFont: UIFont = .body
    static let hintActiveFont: UIFont = .bodyStrong
    static let decorationViewColor: UIColor = .stone
    static let decorationViewActiveColor: UIColor = .primaryBlue
    static let decorationViewHeight: CGFloat = 1.0
    static let decorationViewActiveHeight: CGFloat = 3.0
    static let decorationViewActiveCornerRadius = decorationViewActiveHeight / 2

    static func normalFont(size: NumberInputFontSize) -> UIFont? {
        return UIFont.body(withSize: size.rawValue)
    }

    static func activeFont(size: NumberInputFontSize) -> UIFont? {
        return UIFont.bodyStrong(withSize: size.rawValue)
    }
}

// MARK: - Private extensions

private extension UIView {
    func constraint(withIdentifier identifier: String) -> NSLayoutConstraint? {
        return constraints.first(where: { $0.identifier == identifier })
    }
}

private extension UITextField {
    func updateCursorAfterReplacement(in range: NSRange, with string: String, oldText: String) {
        let newText = text ?? ""
        let oldNumberOfWhitespaces = oldText.components(separatedBy: .whitespaces).count
        let newNumberOfWhitespaces = newText.components(separatedBy: .whitespaces).count
        let offset = newNumberOfWhitespaces - oldNumberOfWhitespaces

        let cursorLocation = position(
            from: beginningOfDocument,
            offset: range.location + string.count + offset
        )

        if let cursorLocation = cursorLocation {
            selectedTextRange = textRange(from: cursorLocation, to: cursorLocation)
        }
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
        setItems(items.map { $0.buttonItem }, animated: false)
    }
}
