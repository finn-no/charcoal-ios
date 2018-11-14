//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class MultiLevelSelectionListItemCell: UITableViewCell {
    private var normalStateImageAsset: ImageAsset {
        return .checkboxOff
    }

    private var partiallySelectedStateImageAsset: ImageAsset {
        return .checkboxPartial
    }

    private var selectedStateImageAsset: ImageAsset {
        return .checkboxOn
    }

    private lazy var separatorLine: UIView = {
        let separatorLine = UIView(frame: .zero)
        separatorLine.backgroundColor = .sardine
        separatorLine.translatesAutoresizingMaskIntoConstraints = false

        return separatorLine
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
    }

    func setSelectionState(_ selectionState: MultiLevelListItemSelectionState) {
        switch selectionState {
        case .none:
            imageView?.image = UIImage(named: normalStateImageAsset)
            textLabel?.textColor = .licorice
        case .partial:
            imageView?.image = UIImage(named: partiallySelectedStateImageAsset)
            textLabel?.textColor = .primaryBlue
        case .selected:
            imageView?.image = UIImage(named: selectedStateImageAsset)
            textLabel?.textColor = .licorice
        }
    }
}

private extension MultiLevelSelectionListItemCell {
    func setup() {
        selectionStyle = .none
        textLabel?.font = .regularBody
        textLabel?.textColor = .licorice
        detailTextLabel?.font = .detail
        detailTextLabel?.textColor = .stone
        imageView?.image = UIImage(named: normalStateImageAsset)

        addSubview(separatorLine)

        NSLayoutConstraint.activate([
            separatorLine.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
            separatorLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: textLabel?.leadingAnchor ?? leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}

extension MultiLevelSelectionListItemCell {
    func configure(for listItem: ListItem) {
        textLabel?.text = listItem.title
        detailTextLabel?.text = listItem.detail
        accessoryType = listItem.showsDisclosureIndicator ? .disclosureIndicator : .none
    }
}
