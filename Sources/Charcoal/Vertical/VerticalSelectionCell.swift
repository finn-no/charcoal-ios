//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import UIKit

final class VerticalSelectionCell: UITableViewCell {
    private lazy var radioButton: AnimatedRadioButtonView = {
        let radioButton = AnimatedRadioButtonView(frame: .zero)
        radioButton.translatesAutoresizingMaskIntoConstraints = false
        return radioButton
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Setup

    func configure(for vertical: Vertical) {
        textLabel?.text = vertical.title
        radioButton.isHighlighted = vertical.isCurrent

        if vertical.isExternal {
            detailTextLabel?.text = "browserText".localized()
            accessoryView = UIImageView(image: UIImage(named: .externalLink))
        } else {
            accessoryView = nil
            detailTextLabel?.text = nil
        }

        let accessibilityPrefix = vertical.isCurrent ? "selected".localized() + ", " : ""
        let accessibilitySuffix = detailTextLabel?.text.map({ ", \($0) " }) ?? ""
        accessibilityLabel = accessibilityPrefix + vertical.title + accessibilitySuffix
    }

    private func setup() {
        separatorInset = .leadingInset(.veryLargeSpacing)
        selectionStyle = .none
        textLabel?.font = .body
        textLabel?.textColor = .licorice
        detailTextLabel?.font = .detail
        detailTextLabel?.textColor = .stone

        addSubview(radioButton)

        NSLayoutConstraint.activate([
            radioButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumSpacing),
            radioButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
