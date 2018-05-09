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

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        textLabel?.textColor = selected ? .primaryBlue : .licorice
        imageView?.image = selected ? UIImage(named: .checkboxActive) : UIImage(named: .checkbox)
    }
}

private extension SelectionListItemCell {
    func setup() {
        selectionStyle = .none
        textLabel?.font = .body
        textLabel?.textColor = .licorice
        detailTextLabel?.font = .detail
        detailTextLabel?.textColor = .stone
        imageView?.image = UIImage(named: .checkbox)

        addSubview(separatorLine)
        
        NSLayoutConstraint.activate([
            separatorLine.heightAnchor.constraint(equalToConstant: 1.0 / contentScaleFactor),
            separatorLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: textLabel?.leadingAnchor ?? leadingAnchor)
            separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}

public extension SelectionListItemCell {
    func configure(for listItem: ListItem) {
        textLabel?.text = listItem.title
        detailTextLabel?.text = listItem.detail
        accessoryType = listItem.showsDisclosureIndicator ? .disclosureIndicator : .none
    }
}
