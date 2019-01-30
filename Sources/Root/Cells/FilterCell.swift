//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol FilterCellDelegate: AnyObject {
    func filterCell(_ filterCell: FilterCell, didTapRemoveSelectedValue: SelectionWithTitle)
}

class FilterCell: UITableViewCell {

    // MARK: - Public properties

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

    var isContextFilter: Bool = false {
        didSet {
            dotView.isHidden = !isContextFilter
            nameLabelLeadingConstraint.isActive = isContextFilter
        }
    }

    override var textLabel: UILabel? {
        return nil
    }

    // MARK: - Private properties

    private let dotSize: CGFloat = 10
    private lazy var nameLabelLeadingConstraint = nameLabel.leadingAnchor.constraint(equalTo: dotView.trailingAnchor, constant: .mediumSpacing)

    private lazy var dotView: UIView = {
        let view = UIView(withAutoLayout: true)
        view.isHidden = true
        view.backgroundColor = .red
        view.layer.cornerRadius = dotSize / 2
        return view
    }()

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
        isContextFilter = false
    }
}

private extension FilterCell {
    func setup() {
        selectionStyle = .none

        contentView.addSubview(dotView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(currentValuesContainer)

        let separatorLine = UIView(frame: .zero)
        separatorLine.backgroundColor = .sardine
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorLine)

        NSLayoutConstraint.activate([
            dotView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .mediumLargeSpacing + .mediumSpacing),
            dotView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dotView.heightAnchor.constraint(equalToConstant: dotSize),
            dotView.widthAnchor.constraint(equalToConstant: dotSize),

            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .mediumSpacing),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.mediumSpacing),
            nameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: .mediumLargeSpacing + .mediumSpacing),

            currentValuesContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            currentValuesContainer.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: .mediumSpacing),
            currentValuesContainer.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: .mediumLargeSpacing),
            currentValuesContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            separatorLine.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
            separatorLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .mediumLargeSpacing + .mediumSpacing),
            separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}

extension FilterCell: CurrentSelectionValuesContainerDelegate {
    func currentSelectionValuesContainerView(_: CurrentSelectionValuesContainer, didTapRemoveSelection selection: SelectionWithTitle) {
        delegate?.filterCell(self, didTapRemoveSelectedValue: selection)
    }
}
