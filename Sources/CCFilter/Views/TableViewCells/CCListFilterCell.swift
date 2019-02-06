//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class CCListFilterCell: UITableViewCell {

    // MARK: - Private properties

    private lazy var iconView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .regularBody
        label.textColor = .licorice
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var detailLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .detail
        label.textColor = .stone
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var detailLabelTrailingConstraint = detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CCListFilterCell {
    func configure(for filterNode: CCFilterNode) {
        titleLabel.text = filterNode.title
        detailLabel.text = String(filterNode.numberOfResults)
        separatorInset = UIEdgeInsets(top: 0, left: 24 + .largeSpacing, bottom: 0, right: 0)

        if filterNode.name == "map" {
            detailLabel.text = nil
            accessoryType = .disclosureIndicator
            iconView.image = UIImage(named: .mapFilterIcon)
            return
        }

        if filterNode.children.isEmpty {
            accessoryType = .none
            detailLabelTrailingConstraint.constant = -.mediumLargeSpacing
        } else {
            accessoryType = .disclosureIndicator
            detailLabelTrailingConstraint.constant = 0
        }

        if filterNode.isSelected {
            iconView.image = UIImage(named: .checkboxOn)
        } else {
            if filterNode.hasSelectedChildren {
                iconView.image = UIImage(named: .checkboxPartial)
            } else {
                iconView.image = UIImage(named: .checkboxOff)
            }
        }
    }
}

private extension CCListFilterCell {
    func setup() {
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .mediumLargeSpacing),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            iconView.widthAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: .mediumLargeSpacing),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .mediumLargeSpacing),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.mediumLargeSpacing),

            detailLabelTrailingConstraint,
            detailLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .mediumLargeSpacing),
            detailLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.mediumLargeSpacing),
        ])
    }
}
