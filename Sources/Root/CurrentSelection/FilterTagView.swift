//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol FilterTagViewDelegate: AnyObject {
    func filterTagViewDidSelectRemove(_ view: FilterTagView)
}

final class FilterTagView: UIView {
    weak var delegate: FilterTagViewDelegate?

    // MARK: - Private vars

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

    // MARK: - Init

    init(title: String) {
        super.init(frame: .zero)
        setup(title: title)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup(title: "")
    }

    // MARK: - Setup

    private func setup(title: String) {
        addSubview(titleLabel)
        addSubview(removeButton)

        layer.cornerRadius = 4
        backgroundColor = .primaryBlue
        titleLabel.text = title

        let buttonInsets = removeButton.imageEdgeInsets.leading + removeButton.imageEdgeInsets.trailing
        let buttonWidth = removeButtonImage.size.width + buttonInsets

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: .mediumSpacing),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.mediumSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumSpacing),
            titleLabel.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor),

            removeButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            removeButton.topAnchor.constraint(equalTo: topAnchor),
            removeButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            removeButton.widthAnchor.constraint(equalToConstant: buttonWidth),
        ])
    }

    // MARK: - Actions

    @objc private func handleRemoveButtonTap() {
        delegate?.filterTagViewDidSelectRemove(self)
    }
}

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
