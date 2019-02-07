//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol FilterTagViewDelegate: AnyObject {
    func filterTagViewDidSelectRemove(_ view: FilterTagView)
}

final class FilterTagView: UIView {
    weak var delegate: FilterTagViewDelegate?

    private lazy var titleLabel: UILabel = {
        let label = UILabel(withAutoLayout: true)
        label.font = .title5
        label.textColor = .milk
        return label
    }()

    private lazy var button: UIButton = {
        let button = UIButton(withAutoLayout: true)
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
        addSubview(button)

        layer.cornerRadius = 4
        backgroundColor = .primaryBlue
        titleLabel.text = title

        let buttonWidth = removeButtonImage.size.width + button.imageEdgeInsets.leading + button.imageEdgeInsets.trailing

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: .mediumSpacing),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.mediumSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumSpacing),
            titleLabel.trailingAnchor.constraint(equalTo: button.leadingAnchor),

            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.widthAnchor.constraint(equalToConstant: buttonWidth), // 22)
        ])
    }

    // MARK: - Actions

    @objc private func handleRemoveButtonTap() {
        delegate?.filterTagViewDidSelectRemove(self)
    }
}
