//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class VerticalSelectionCell: UITableViewCell {
    private var normalStateImageAsset: ImageAsset {
        return .radioButtonOff
    }

    private var selectedStateImageAsset: ImageAsset {
        return .radioButtonOn
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
        super.setSelected(false, animated: false)
    }

    public func setSelectionMarker(visible: Bool) {
        textLabel?.textColor = visible ? .primaryBlue : .licorice
        setSelectionIndicator(selected: visible)
    }
}

private extension VerticalSelectionCell {
    func setup() {
        selectionStyle = .none
        textLabel?.font = .body
        textLabel?.textColor = .licorice
        detailTextLabel?.font = .detail
        detailTextLabel?.textColor = .stone
        imageView?.image = UIImage(named: normalStateImageAsset)

        addSubview(separatorLine)

        NSLayoutConstraint.activate([
            separatorLine.heightAnchor.constraint(equalToConstant: 1.0 / contentScaleFactor),
            separatorLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: textLabel?.leadingAnchor ?? leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    func setSelectionIndicator(selected: Bool) {
        imageView?.image = selected ? UIImage(named: selectedStateImageAsset) : UIImage(named: normalStateImageAsset)
    }
}

extension VerticalSelectionCell {
    func configure(for vertical: Vertical) {
        textLabel?.text = vertical.title
        setSelectionIndicator(selected: vertical.isCurrent)
        if vertical.isExternal {
            detailTextLabel?.text = "opens_in_browser".localized()
            accessoryView = UIImageView(image: UIImage(named: .externalLink))
        } else {
            accessoryView = nil
            detailTextLabel?.text = nil
        }
    }
}
