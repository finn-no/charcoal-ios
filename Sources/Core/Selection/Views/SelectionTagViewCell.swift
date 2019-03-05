//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol SelectionTagViewCellDelegate: AnyObject {
    func selectionTagViewCellDidSelectRemove(_ cell: SelectionTagViewCell)
}

final class SelectionTagViewCell: UICollectionViewCell {
    weak var delegate: SelectionTagViewCellDelegate?

    // MARK: - Private properties

    private lazy var titleLabel: UILabel = {
        let label = UILabel(withAutoLayout: true)
        label.font = SelectionTagViewCell.titleFont
        label.textColor = .milk
        label.textAlignment = .center
        return label
    }()

    private lazy var removeButton: UIButton = {
        let button = RemoveButton(withAutoLayout: true)
        button.adjustsImageWhenHighlighted = false
        button.imageEdgeInsets = SelectionTagViewCell.removeButtonEdgeInsets
        button.setImage(UIImage(named: .removeFilterValue), for: .normal)
        button.addTarget(self, action: #selector(handleRemoveButtonTap), for: .touchUpInside)
        return button
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Overrides

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return hitView == removeButton ? hitView : nil
    }

    override var backgroundColor: UIColor? {
        didSet {
            if let backgroundColor = backgroundColor, backgroundColor.cgColor.alpha == 0 {
                self.backgroundColor = oldValue
            }
        }
    }

    // MARK: - Setup

    func configure(withTitle title: String?, isValid: Bool) {
        titleLabel.text = title
        backgroundColor = isValid ? .primaryBlue : .cherry
    }

    private func setup() {
        layer.cornerRadius = 4
        backgroundColor = .primaryBlue

        contentView.addSubview(titleLabel)
        contentView.addSubview(removeButton)

        let leading = SelectionTagViewCell.titleLeading
        let buttonWidth = SelectionTagViewCell.removeButtonWidth

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: leading),
            titleLabel.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            removeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            removeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            removeButton.widthAnchor.constraint(equalToConstant: buttonWidth),
        ])
    }

    // MARK: - Actions

    @objc private func handleRemoveButtonTap() {
        delegate?.selectionTagViewCellDidSelectRemove(self)
    }
}

// MARK: - Size calculations

extension SelectionTagViewCell {
    static let height: CGFloat = 30
    static let minWidth: CGFloat = 56

    static func width(for title: String) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = title.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: titleFont],
            context: nil
        )

        return ceil(boundingBox.width) + titleLeading + removeButtonWidth
    }

    private static let titleFont = UIFont.title5
    private static let titleLeading: CGFloat = .mediumSpacing
    private static let removeButtonEdgeInsets = UIEdgeInsets(leading: .mediumSpacing, trailing: .mediumSpacing)

    private static var removeButtonWidth: CGFloat {
        return 14 + removeButtonEdgeInsets.leading + removeButtonEdgeInsets.trailing
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
