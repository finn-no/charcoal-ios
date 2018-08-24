//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class SearchTermSuggestionCell: UITableViewCell {
    lazy var suggestionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body
        label.textColor = .licorice
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = nil
    }

    func setup() {
        imageView?.image = UIImage(named: .search)
        contentView.addSubview(suggestionLabel)

        let anchorForLabelLeadingAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>
        if let imageView = imageView {
            anchorForLabelLeadingAnchor = imageView.trailingAnchor
        } else {
            anchorForLabelLeadingAnchor = contentView.leadingAnchor
        }

        NSLayoutConstraint.activate([
            suggestionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            suggestionLabel.leadingAnchor.constraint(equalTo: anchorForLabelLeadingAnchor, constant: .mediumSpacing),
            suggestionLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
        ])
    }
}
