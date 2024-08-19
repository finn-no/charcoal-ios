//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import UIKit
import Warp

final class VerticalCell: UITableViewCell {
    private lazy var radioButton: RadioButtonView = {
        let radioButton = RadioButtonView()
        radioButton.translatesAutoresizingMaskIntoConstraints = false
        return radioButton
    }()

    private lazy var externalVerticalIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: .webview).withRenderingMode(.alwaysTemplate))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .chevron
        return imageView
    }()

    private lazy var calloutView: DetailCalloutView = {
        let calloutView = DetailCalloutView(direction: .left, numberOfLines: 1)
        calloutView.translatesAutoresizingMaskIntoConstraints = false
        return calloutView
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

    override func prepareForReuse() {
        super.prepareForReuse()
        calloutView.removeFromSuperview()
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

        if let calloutText = vertical.calloutText, let textLabel = textLabel {
            addSubview(calloutView)
            NSLayoutConstraint.activate([
                calloutView.leadingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: Warp.Spacing.spacing200),
                calloutView.centerYAnchor.constraint(equalTo: centerYAnchor),
                calloutView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            ])
            calloutView.configure(withText: calloutText)
        } else {
            calloutView.removeFromSuperview()
        }
    }

    private func setup() {
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = .backgroundSubtle
        self.selectedBackgroundView = selectedBackgroundView
        backgroundColor = .clear

        separatorInset = .leadingInset(56)

        textLabel?.font = .bodyRegular
        textLabel?.textColor = .text
        textLabel?.adjustsFontForContentSizeCategory = true

        addSubview(radioButton)
        addSubview(externalVerticalIcon)
        externalVerticalIcon.isHidden = true

        NSLayoutConstraint.activate([
            radioButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Warp.Spacing.spacing200),
            radioButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            externalVerticalIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Warp.Spacing.spacing200 + Warp.Spacing.spacing50),
            externalVerticalIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
