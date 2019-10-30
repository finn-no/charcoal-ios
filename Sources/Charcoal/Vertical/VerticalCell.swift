//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import UIKit

final class VerticalCell: UITableViewCell {
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

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Overrides

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutAccessoryView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let isRadioButtonHighlighted = radioButton.isHighlighted
        super.setSelected(selected, animated: animated)
        radioButton.isHighlighted = isRadioButtonHighlighted
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let isRadioButtonHighlighted = radioButton.isHighlighted
        super.setHighlighted(highlighted, animated: animated)
        radioButton.isHighlighted = isRadioButtonHighlighted
    }

    // MARK: - Setup

    func configure(for vertical: Vertical) {
        textLabel?.text = vertical.title
        radioButton.isHighlighted = vertical.isCurrent

        if vertical.isExternal {
            detailTextLabel?.text = "browserText".localized()

            let accessoryView = UIImageView(image: UIImage(named: .webview).withRenderingMode(.alwaysTemplate))
            accessoryView.tintColor = .chevron
            self.accessoryView = accessoryView
        } else {
            accessoryView = nil
            detailTextLabel?.text = nil
        }

        let accessibilityPrefix = vertical.isCurrent ? "selected".localized() + ", " : ""
        let accessibilitySuffix = detailTextLabel?.text.map { ", \($0) " } ?? ""

        accessibilityLabel = accessibilityPrefix + vertical.title + accessibilitySuffix
    }

    private func setup() {
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = .defaultCellSelectedBackgroundColor
        self.selectedBackgroundView = selectedBackgroundView

        separatorInset = .leadingInset(56)

        textLabel?.font = .bodyRegular
        textLabel?.textColor = .textPrimary
        textLabel?.adjustsFontForContentSizeCategory = true

        detailTextLabel?.font = .detail
        detailTextLabel?.textColor = .stone
        detailTextLabel?.adjustsFontForContentSizeCategory = true

        addSubview(radioButton)

        NSLayoutConstraint.activate([
            radioButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumLargeSpacing),
            radioButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
