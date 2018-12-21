//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class MapFilterCell: UITableViewCell {
    private var normalStateImageAsset: ImageAsset {
        return .mapFilterIcon
    }

    private var selectedStateImageAsset: ImageAsset {
        return .mapFilterIcon
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
        if selected {
            imageView?.image = UIImage(named: selectedStateImageAsset)
            textLabel?.textColor = .licorice
        } else {
            imageView?.image = UIImage(named: normalStateImageAsset)
            textLabel?.textColor = .licorice
        }
    }
}

private extension MapFilterCell {
    func setup() {
        selectionStyle = .none
        textLabel?.font = .regularBody
        textLabel?.textColor = .licorice
        detailTextLabel?.font = .detail
        detailTextLabel?.textColor = .stone
        imageView?.image = UIImage(named: normalStateImageAsset)
        imageView?.contentMode = .center

        addSubview(separatorLine)

        NSLayoutConstraint.activate([
            separatorLine.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
            separatorLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: textLabel?.leadingAnchor ?? leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}

extension MapFilterCell {
    func configure(title: String, showDisclosureIndicator: Bool, selected: Bool) {
        textLabel?.text = title
        accessoryType = showDisclosureIndicator ? .disclosureIndicator : .none
        isSelected = selected
    }
}
