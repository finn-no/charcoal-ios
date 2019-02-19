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

    private lazy var selectionTagsContainerView: SelectionTagsContainerView = {
        let view = SelectionTagsContainerView(withAutoLayout: true)
        view.delegate = self
        return view
    }()

    private lazy var hairLine: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .sardine
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        selectionStyle = .none
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        selectionTagsContainerView.configure(with: [], isValid: true)
    }

    // MARK: - Setup

    func configure(withTitle title: String, selectionTitles: [String], isValid: Bool) {
        titleLabel.text = title
        selectionTagsContainerView.configure(with: selectionTitles, isValid: isValid)
    }

    private func setup() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(selectionTagsContainerView)
        contentView.addSubview(hairLine)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .mediumLargeSpacing),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.mediumLargeSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .mediumLargeSpacing + .mediumSpacing),

            selectionTagsContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionTagsContainerView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: .mediumSpacing),
            selectionTagsContainerView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: .mediumLargeSpacing),
            selectionTagsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            hairLine.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
            hairLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            hairLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .mediumLargeSpacing + .mediumSpacing),
            hairLine.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}

// MARK: - SelectionTagsContainerViewDelegate

extension CCRootFilterCell: SelectionTagsContainerViewDelegate {
    func selectionTagsContainerView(_ view: SelectionTagsContainerView, didRemoveTagAt index: Int) {
        delegate?.rootFilterCell(self, didRemoveItemAt: index)
    }
}
