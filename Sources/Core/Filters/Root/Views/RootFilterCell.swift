//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol RootFilterCellDelegate: AnyObject {
    func rootFilterCell(_ cell: RootFilterCell, didRemoveItemAt index: Int)
}

final class RootFilterCell: UITableViewCell {
    weak var delegate: RootFilterCellDelegate?

    // MARK: - Private properties

    private lazy var contextMark: UIView = {
        let view = UIView(withAutoLayout: true)
        view.backgroundColor = .red
        view.layer.cornerRadius = 5
        return view
    }()

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

    private lazy var titleToContextMarkConstraint = titleLabel.leadingAnchor.constraint(equalTo: contextMark.trailingAnchor, constant: .mediumSpacing)

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

    func configure(withTitle title: String, selectionTitles: [String], isValid: Bool, kind: Filter.Kind = .normal) {
        titleLabel.text = title
        selectionTagsContainerView.configure(with: selectionTitles, isValid: isValid)

        switch kind {
        case .normal:
            contextMark.isHidden = true
            titleToContextMarkConstraint.isActive = false
        case .context:
            contextMark.isHidden = false
            titleToContextMarkConstraint.isActive = true
        }
    }

    private func setup() {
        contentView.addSubview(contextMark)
        contentView.addSubview(titleLabel)
        contentView.addSubview(selectionTagsContainerView)
        contentView.addSubview(hairLine)

        // Setting a low priority here means 'titleToMarkConstraint' will have higher priority
        let titleToContentViewConstraint = titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .mediumLargeSpacing + .mediumSpacing)
        titleToContentViewConstraint.priority = .defaultLow

        NSLayoutConstraint.activate([
            contextMark.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .mediumLargeSpacing + .mediumSpacing),
            contextMark.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contextMark.widthAnchor.constraint(equalToConstant: 10),
            contextMark.heightAnchor.constraint(equalToConstant: 10),

            titleToContentViewConstraint,
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .mediumLargeSpacing),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.mediumLargeSpacing),

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

extension RootFilterCell: SelectionTagsContainerViewDelegate {
    func selectionTagsContainerView(_ view: SelectionTagsContainerView, didRemoveTagAt index: Int) {
        delegate?.rootFilterCell(self, didRemoveItemAt: index)
    }
}
