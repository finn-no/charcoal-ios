//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol SelectionTagViewDelegate: AnyObject {
    func selectionTagViewDidSelectRemove(_ view: SelectionTagView)
}

final class SelectionTagView: UIView {
    weak var delegate: SelectionTagViewDelegate?

    // MARK: - Private properties

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(withAutoLayout: true)
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.backgroundColor = .clear
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel(withAutoLayout: true)
        label.font = .title5
        label.textColor = .milk
        return label
    }()

    private lazy var removeButton: UIButton = {
        let button = RemoveButton(withAutoLayout: true)
        button.adjustsImageWhenHighlighted = false
        button.imageEdgeInsets = UIEdgeInsets(leading: .smallSpacing, trailing: .smallSpacing)
        button.setImage(removeButtonImage, for: .normal)
        button.addTarget(self, action: #selector(handleRemoveButtonTap), for: .touchUpInside)
        return button
    }()

    private lazy var removeButtonImage = UIImage(named: .removeFilterValue)
    private lazy var stackViewTrailingConstraint = stackView.trailingAnchor.constraint(equalTo: trailingAnchor)

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Setup

    func configure(withTitle title: String?, isValid: Bool, showRemoveButton: Bool) {
        titleLabel.text = title
        backgroundColor = isValid ? .primaryBlue : .cherry
        removeButton.isHidden = !showRemoveButton
        stackViewTrailingConstraint.constant = showRemoveButton ? 0 : -.mediumSpacing
    }

    private func setup() {
        layer.cornerRadius = 4
        backgroundColor = .primaryBlue

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(removeButton)

        addSubview(stackView)

        let buttonInsets = removeButton.imageEdgeInsets.leading + removeButton.imageEdgeInsets.trailing
        let buttonWidth = removeButtonImage.size.width + buttonInsets

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumSpacing),
            stackViewTrailingConstraint,
        ])

        removeButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
    }

    // MARK: - Actions

    @objc private func handleRemoveButtonTap() {
        delegate?.selectionTagViewDidSelectRemove(self)
    }
}

// MARK: - Private types

private final class RemoveButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            updateAlpha(opaque: !isHighlighted)
        }
    }

    override var isSelected: Bool {
        didSet {
            updateAlpha(opaque: !isSelected)
        }
    }

    private func updateAlpha(opaque: Bool) {
        alpha = opaque ? 1 : 0.7
    }
}
