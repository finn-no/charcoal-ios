//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol FilterCellDelegate: AnyObject {
    func filterCell(_ filterCell: FilterCell, didTapRemoveSelectedValue: SelectionWithTitle)
}

class FilterCell: UITableViewCell {
    private lazy var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .regularBody
        label.textColor = .licorice
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private lazy var selectionTagsContainerView: SelectionTagsContainerView = {
        let view = SelectionTagsContainerView(withAutoLayout: true)
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override var textLabel: UILabel? {
        return nil
    }

    weak var delegate: FilterCellDelegate?

    var filterName: String? {
        didSet {
            nameLabel.text = filterName
        }
    }

    var selectedValues: [SelectionWithTitle]? {
        didSet {
            selectionTagsContainerView.configure(with: selectedValues)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        selectedValues = nil
        filterName = nil
    }
}

private extension FilterCell {
    func setup() {
        selectionStyle = .none

        contentView.addSubview(nameLabel)
        contentView.addSubview(selectionTagsContainerView)

        let separatorLine = UIView(frame: .zero)
        separatorLine.backgroundColor = .sardine
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorLine)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .mediumSpacing),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.mediumSpacing),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .mediumLargeSpacing + .mediumSpacing),

            selectionTagsContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionTagsContainerView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: .mediumSpacing),
            selectionTagsContainerView.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: .mediumLargeSpacing),
            selectionTagsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            separatorLine.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
            separatorLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}

// MARK: - SelectionTagsContainerViewDelegate

extension FilterCell: SelectionTagsContainerViewDelegate {
    func selectionTagsContainerView(_ view: SelectionTagsContainerView, didTapRemoveSelection selection: SelectionWithTitle) {
        delegate?.filterCell(self, didTapRemoveSelectedValue: selection)
    }
}
