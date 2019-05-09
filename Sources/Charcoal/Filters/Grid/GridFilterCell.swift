//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

final class GridFilterCell: UICollectionViewCell {
    private lazy var titleLabel: UILabel = {
        let label = UILabel(withAutoLayout: true)
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
            backgroundColor = .primaryBlue
            layer.borderColor = UIColor.primaryBlue.cgColor
            titleLabel.font = UIFont.bodyStrong.withSize(20)
            titleLabel.textColor = .milk
        } else {
            backgroundColor = .milk
            layer.borderColor = UIColor.sardine.cgColor
            titleLabel.font = UIFont.bodyRegular.withSize(20)
            titleLabel.textColor = .licorice
        }
    }
}
