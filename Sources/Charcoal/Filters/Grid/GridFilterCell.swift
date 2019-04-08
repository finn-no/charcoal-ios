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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupStyles()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        backgroundColor = isSelected ? .backgroundSelected : .background
        layer.borderColor = isSelected ? .borderSelected : .border
        titleLabel.font = isSelected ? .titleSelected : .title
        titleLabel.textColor = isSelected ? .titleSelected : .title
    }
}

// MARK: - Private extension

private extension UIColor {
    static let title = UIColor.licorice
    static let titleSelected = UIColor.milk
    static let background = UIColor.milk
    static let backgroundSelected = UIColor.primaryBlue
}

private extension CGColor {
    static let border = UIColor.sardine.cgColor
    static let borderSelected = UIColor.primaryBlue.cgColor
}

private extension UIFont {
    static let title = UIFont(name: FontType.medium.rawValue, size: 20)
    static let titleSelected = UIFont(name: FontType.bold.rawValue, size: 20)
}
