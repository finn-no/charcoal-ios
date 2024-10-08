//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

final class GridFilterCell: UICollectionViewCell {
    private lazy var titleLabel: UILabel = {
        let label = UILabel(withAutoLayout: true)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        return label
    }()

    override var isSelected: Bool {
        didSet {
            setupStyles()
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupStyles()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    func configure(withTitle title: String, accessibilityPrefix: String) {
        titleLabel.text = title
        accessibilityValue = "\(accessibilityPrefix) \(title)"
    }

    private func setup() {
        isAccessibilityElement = true

        layer.cornerRadius = frame.width / 4
        layer.borderWidth = 2.0

        contentView.addSubview(titleLabel)
        titleLabel.fillInSuperview()
    }

    private func setupStyles() {
        if isSelected {
            backgroundColor = .backgroundPrimary
            layer.borderColor = UIColor.backgroundPrimary.cgColor
            titleLabel.font = UIFont.bodyStrong
            titleLabel.textColor = .textInverted
        } else {
            backgroundColor = Theme.mainBackground
            layer.borderColor = UIColor.backgroundDisabled.cgColor
            titleLabel.font = UIFont.body
            titleLabel.textColor = .text
        }
    }
}
