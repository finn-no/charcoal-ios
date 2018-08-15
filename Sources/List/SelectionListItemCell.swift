//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class SelectionListItemCell: UITableViewCell {
    public enum SelectionIndicatorType {
        case radioButton
        case checkbox

        var normalStateImageAsset: ImageAsset {
            switch self {
            case .radioButton:
                return .radioButtonOff
            case .checkbox:
                return .checkboxOff
            }
        }

        var selectedStateImageAsset: ImageAsset {
            switch self {
            case .radioButton:
                return .radioButtonOn
            case .checkbox:
                return .checkboxOn
            }
        }

        static let `default` = SelectionIndicatorType.checkbox
    }

    private lazy var separatorLine: UIView = {
        let separatorLine = UIView(frame: .zero)
        separatorLine.backgroundColor = .sardine
        separatorLine.translatesAutoresizingMaskIntoConstraints = false

        return separatorLine
    }()

    public var selectionIndicatorType = SelectionIndicatorType.default {
        didSet {
            setSelectionIndicator(selected: isSelected)
        }
    }

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
        setSelectionIndicator(selected: selected)
    }
}

private extension SelectionListItemCell {
    func setup() {
        selectionStyle = .none
        textLabel?.font = .body
        textLabel?.textColor = .licorice
        detailTextLabel?.font = .detail
        detailTextLabel?.textColor = .stone
        imageView?.image = UIImage(named: selectionIndicatorType.normalStateImageAsset)

        addSubview(separatorLine)

        NSLayoutConstraint.activate([
            separatorLine.heightAnchor.constraint(equalToConstant: 1.0 / contentScaleFactor),
            separatorLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: textLabel?.leadingAnchor ?? leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    func setSelectionIndicator(selected: Bool) {
        imageView?.image = selected ? UIImage(named: selectionIndicatorType.selectedStateImageAsset) : UIImage(named: selectionIndicatorType.normalStateImageAsset)
    }
}

public extension SelectionListItemCell {
    func configure(for listItem: ListItem) {
        textLabel?.text = listItem.title
        detailTextLabel?.text = listItem.detail
        accessoryType = listItem.showsDisclosureIndicator ? .disclosureIndicator : .none
    }
}
