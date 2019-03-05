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

    // MARK: - Overrides

    override func setSelected(_ selected: Bool, animated: Bool) {
        let isCheckboxHighlighted = checkbox.isHighlighted
        super.setSelected(selected, animated: animated)
        checkbox.isHighlighted = isCheckboxHighlighted
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let isCheckboxHighlighted = checkbox.isHighlighted
        super.setHighlighted(highlighted, animated: animated)
        checkbox.isHighlighted = isCheckboxHighlighted
    }

    // MARK: - Setup

    func configure(with viewModel: ListFilterCellViewModel, animated: Bool) {
        super.configure(with: viewModel)

        switch viewModel.accessoryStyle {
        case .chevron:
            selectionStyle = .default
            chevronImageView.isHidden = true
        case .external:
            selectionStyle = .default
            chevronImageView.isHidden = false
            chevronImageView.image = UIImage(named: .webview).withRenderingMode(.alwaysTemplate)
            bringSubviewToFront(chevronImageView)
        case .none:
            selectionStyle = .none
            chevronImageView.isHidden = true
        }

        if viewModel.checkboxStyle == .partiallySelected {
            checkbox.image = UIImage(named: .checkboxPartial)
        } else if animated {
            checkbox.isHighlighted = false
            animateSelection(isSelected: viewModel.isSelected)
        }
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
