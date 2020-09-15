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

    private lazy var externalVerticalIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: .webview).withRenderingMode(.alwaysTemplate))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .chevron
        return imageView
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

        radioButton.isHidden = vertical.isExternal
        externalVerticalIcon.isHidden = !radioButton.isHidden

        let accessibilityPrefix = vertical.isCurrent ? "selected".localized() + ", " : ""
        let accessibilitySuffix = vertical.isExternal ? ", " + "browserText".localized() + " " : ""

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

        addSubview(radioButton)
        addSubview(externalVerticalIcon)
        externalVerticalIcon.isHidden = true

        NSLayoutConstraint.activate([
            radioButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .spacingM),
            radioButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            externalVerticalIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .spacingM + .spacingXS),
            externalVerticalIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
