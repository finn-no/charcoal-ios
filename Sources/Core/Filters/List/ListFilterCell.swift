//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

final class ListFilterCell: CheckboxTableViewCell {
    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView(withAutoLayout: true)
        imageView.backgroundColor = .milk
        imageView.tintColor = .chevron
        imageView.isHidden = true
        return imageView
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    func configure(with viewModel: ListFilterCellViewModel, animated: Bool) {
        super.configure(with: viewModel)

        if viewModel.accessoryStyle == .external {
            chevronImageView.isHidden = false
            chevronImageView.image = UIImage(named: .webview).withRenderingMode(.alwaysTemplate)
            bringSubviewToFront(chevronImageView)
        } else {
            chevronImageView.isHidden = true
        }

        if viewModel.checkboxStyle == .partiallySelected {
            checkbox.image = UIImage(named: .checkboxPartial)
        } else if animated {
            checkbox.isHighlighted = false
            animateSelection(isSelected: viewModel.isSelected)
        }

        selectionStyle = .none
    }

    private func setup() {
        titleLabel.font = .regularBody
        addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            chevronImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.smallSpacing * 3),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14),
            chevronImageView.widthAnchor.constraint(equalTo: chevronImageView.heightAnchor),
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
