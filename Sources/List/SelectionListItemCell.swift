//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class SelectionListItemCell: UITableViewCell, Identifiable {
    lazy var separatorLine: UIView = {
        let separatorLine = UIView(frame: .zero)
        separatorLine.backgroundColor = .sardine
        separatorLine.translatesAutoresizingMaskIntoConstraints = false

        return separatorLine
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        separatorLine.removeFromSuperview()
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        textLabel?.textColor = selected ? .primaryBlue : .licorice
        imageView?.image = selected ? UIImage(named: .checkboxActive, in: .filterKit) : UIImage(named: .checkbox, in: .filterKit)
    }
}

private extension SelectionListItemCell {
    func setup() {
        selectionStyle = .none
        textLabel?.font = .body
        textLabel?.textColor = .licorice
        detailTextLabel?.font = .detail
        detailTextLabel?.textColor = .stone
        imageView?.image = UIImage(named: .checkbox, in: .filterKit)

        addSubview(separatorLine)

        NSLayoutConstraint.activate([
            separatorLine.heightAnchor.constraint(equalToConstant: 1.0 / contentScaleFactor),
            separatorLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        if let textlabel = self.textLabel {
            separatorLine.leadingAnchor.constraint(equalTo: textlabel.leadingAnchor).isActive = true
        } else {
            separatorLine.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        }
    }
}

public extension SelectionListItemCell {
    func configure(for listItem: ListItem) {
        textLabel?.text = listItem.title
        detailTextLabel?.text = listItem.detail
        accessoryType = listItem.showsDisclosureIndicator ? .disclosureIndicator : .none
    }
}
