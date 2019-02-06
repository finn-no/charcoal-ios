//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol CCFilterSelectionViewDelegate: class {
    func selectionView(_ selectionView: CCFilterSelectionView, didRemoveItemAt index: Int)
}

protocol CCFilterSelectionView {
    var contentWidth: CGFloat { get }
    var delegate: CCFilterSelectionViewDelegate? { get set }
    func add(titles: [String])
}

class CCCollapsedSelectionView: UIView, CCFilterSelectionView {

    // MARK: - Public properties

    weak var delegate: CCFilterSelectionViewDelegate?

    var contentWidth: CGFloat {
        return textLabel.intrinsicContentSize.width
    }

    // MARK: - Private properties

    private lazy var textLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .title5
        label.textColor = .milk
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 4
        backgroundColor = .primaryBlue
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func add(titles: [String]) {
        if titles.count > 1 {
            textLabel.text = "(\(titles.count)) \(titles.joined(separator: ", "))"
        } else {
            textLabel.text = "\(titles.joined(separator: ", "))"
        }
    }
}

private extension CCCollapsedSelectionView {
    func setup() {
        addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumSpacing),
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: .mediumSpacing),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.mediumSpacing),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.mediumSpacing),
        ])
    }
}
