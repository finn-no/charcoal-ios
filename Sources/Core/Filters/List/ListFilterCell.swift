//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

final class ListFilterCell: CheckboxTableViewCell {
    private lazy var chevronImageView = UIImageView(withAutoLayout: true)

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    func configure(with viewModel: ListFilterCellViewModel) {
        super.configure(with: viewModel)

        separatorInset = .leadingInset(52)

        if viewModel.accessoryStyle == .external {
            chevronImageView.isHidden = false
            chevronImageView.image = UIImage(named: .webview)
            bringSubviewToFront(chevronImageView)
        } else {
            chevronImageView.isHidden = true
        }

        if viewModel.checkboxStyle == .partiallySelected {
            checkbox.image = UIImage(named: .checkboxPartial)
        }
    }

    private func setup() {
        // selectionStyle = .none
        separatorInset = .leadingInset(24 + .largeSpacing)

        titleLabel.font = .regularBody
        chevronImageView.backgroundColor = .milk
        chevronImageView.isHidden = true

        addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            chevronImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.smallSpacing * 3),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14),
            chevronImageView.widthAnchor.constraint(equalTo: chevronImageView.heightAnchor),
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
