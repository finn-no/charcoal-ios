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

    private lazy var currentValuesContainer: CurrentSelectionValuesContainerView = {
        let view = CurrentSelectionValuesContainerView()
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
            currentValuesContainer.configure(with: selectedValues)
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
        contentView.addSubview(currentValuesContainer)

        let separatorLine = UIView(frame: .zero)
        separatorLine.backgroundColor = .sardine
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorLine)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .mediumSpacing),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.mediumSpacing),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .mediumLargeSpacing + .mediumSpacing),

            currentValuesContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            currentValuesContainer.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: .mediumSpacing),
            currentValuesContainer.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: .mediumLargeSpacing),
            currentValuesContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            separatorLine.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
            separatorLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}

extension FilterCell: CurrentSelectionValuesContainerDelegate {
    func currentSelectionValuesContainerView(_: CurrentSelectionValuesContainer, didTapRemoveSelection selection: SelectionWithTitle) {
        delegate?.filterCell(self, didTapRemoveSelectedValue: selection)
    }
}
