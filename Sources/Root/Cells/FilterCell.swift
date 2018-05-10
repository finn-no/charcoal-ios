//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol FilterCellDelegate: AnyObject {
    func filterCell(_ filterCell: FilterCell, didTapRemoveSelectedValueAtIndex: Int)
}

class FilterCell: UITableViewCell, Identifiable {
    private lazy var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body
        label.textColor = .licorice
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private lazy var currentValuesContainer: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = .smallSpacing
        stackView.backgroundColor = .clear
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        return stackView
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

    var selectedValues: [String]? {
        didSet {
            currentValuesContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
            selectedValues?.forEach { selectedValue in
                let button = RemoveFilterValueButton(title: selectedValue)
                button.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([button.heightAnchor.constraint(equalToConstant: 30)])
                currentValuesContainer.addArrangedSubview(button)
                button.addTarget(self, action: #selector(didTapRemoveButton(_:)), for: .touchUpInside)
            }
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
            nameLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),

            currentValuesContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            currentValuesContainer.topAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.topAnchor),
            currentValuesContainer.heightAnchor.constraint(equalToConstant: 44),
            currentValuesContainer.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: .smallSpacing),
            currentValuesContainer.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),

            separatorLine.heightAnchor.constraint(equalToConstant: 1.0 / contentScaleFactor),
            separatorLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    @objc func didTapRemoveButton(_ sender: UIButton) {
        guard let tappedIndex = currentValuesContainer.arrangedSubviews.index(of: sender) else {
            return
        }
        delegate?.filterCell(self, didTapRemoveSelectedValueAtIndex: tappedIndex)
    }
}

private class RemoveFilterValueButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)
        setup(title: title)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup(title: "")
    }

    private func setup(title: String) {
        layer.cornerRadius = 4
        backgroundColor = .primaryBlue
        titleLabel?.font = .title5
        setTitleColor(.milk, for: .normal)
        contentEdgeInsets = UIEdgeInsets(leading: .mediumSpacing, trailing: .mediumSpacing)
        imageEdgeInsets = UIEdgeInsets(leading: .smallSpacing)
        setImage(UIImage(named: .removeFilterValue), for: .normal)
        setTitle(title, for: .normal)
    }

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        var imageRect = super.imageRect(forContentRect: contentRect)
        imageRect.origin.x = contentRect.maxX - imageRect.width - imageEdgeInsets.right + imageEdgeInsets.left
        return imageRect
    }

    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        var titleRect = super.titleRect(forContentRect: contentRect)
        titleRect.origin.x = titleRect.minX - imageRect(forContentRect: contentRect).width
        return titleRect
    }
}
