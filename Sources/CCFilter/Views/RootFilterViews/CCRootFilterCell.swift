//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol CCRootFilterCellDelegate: AnyObject {
    func rootFilterCell(_ cell: CCRootFilterCell, didRemoveItemAt index: Int)
}

class CCRootFilterCell: UITableViewCell {
    weak var delegate: CCRootFilterCellDelegate?

    // MARK: - Private properties

    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .regularBody
        label.textColor = .licorice
        return label
    }()

    private lazy var collectionSelectionView: CCCollectionSelectionView = {
        let view = CCCollectionSelectionView(frame: .zero)
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var collapsedSelectionView: CCCollapsedSelectionView = {
        let view = CCCollapsedSelectionView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var hairLine: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .sardine
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        selectionStyle = .none
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let contentTooWide = collectionSelectionView.contentWidth > collectionSelectionView.frame.width
        collectionSelectionView.isHidden = contentTooWide
        collapsedSelectionView.isHidden = !contentTooWide
    }
}

extension CCRootFilterCell {
    func configure(withTitle title: String, selectionTitles: [String]) {
        titleLabel.text = title
        collectionSelectionView.add(titles: selectionTitles)
        collapsedSelectionView.add(titles: selectionTitles)
    }
}

extension CCRootFilterCell: CCFilterSelectionViewDelegate {
    func selectionView(_ selectionView: CCFilterSelectionView, didRemoveItemAt index: Int) {
        delegate?.rootFilterCell(self, didRemoveItemAt: index)
    }
}

private extension CCRootFilterCell {
    func setup() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(collectionSelectionView)
        contentView.addSubview(collapsedSelectionView)
        contentView.addSubview(hairLine)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .mediumLargeSpacing),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.mediumLargeSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .mediumLargeSpacing + .mediumSpacing),

            collectionSelectionView.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: .mediumSpacing),
            collectionSelectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionSelectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionSelectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            collapsedSelectionView.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: .mediumSpacing),
            collapsedSelectionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            collapsedSelectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            hairLine.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
            hairLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            hairLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .mediumLargeSpacing + .mediumSpacing),
            hairLine.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}
