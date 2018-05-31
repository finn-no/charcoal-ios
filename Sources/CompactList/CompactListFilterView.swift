//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class CompactListFilterView: UIControl {
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ItemCell.self, forCellWithReuseIdentifier: String(describing: ItemCell.self))
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .clear

        return collectionView
    }()

    public typealias FilterValue = String
    public let values: [FilterValue]
    public var accessibilityValuesPrefix: String?

    public init(values: [FilterValue]) {
        self.values = values
        super.init(frame: .zero)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension CompactListFilterView {
    var selectedValues: [FilterValue]? {
        let selectedIndexes = collectionView.indexPathsForSelectedItems?.map { $0.row }
        let selectedValues = selectedIndexes?.map { values[$0] }

        return selectedValues
    }
}

private extension CompactListFilterView {
    struct Style {
        static let itemSize = CGSize(width: 58, height: 58)
        static let numberOfItemsPerRow = 5
        static let itemNormalTextColor = UIColor.licorice
        static let itemSelectedTextColor = UIColor.milk
        static let itemNormalBackgroundColor = UIColor.milk
        static let itemSelectedBackgroundColor = UIColor.primaryBlue
        static let itemNormalFont = UIFont(name: FontType.medium.rawValue, size: 20)
        static let itemSelectedFont = UIFont(name: FontType.bold.rawValue, size: 20)
        static let itemBorderColor = UIColor.sardine
        static let itemBorderWidth: CGFloat = 2.0
    }

    func setup() {
        addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}

extension CompactListFilterView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return values.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ItemCell.self), for: indexPath) as! ItemCell
        cell.value = values[indexPath.row]
        cell.accessibilityValuePrefix = accessibilityValuesPrefix
        return cell
    }
}

extension CompactListFilterView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = (collectionView.frame.width / CGFloat(Style.numberOfItemsPerRow)) - .mediumSpacing

        return CGSize(width: side, height: side)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .mediumSpacing
    }
}

extension CompactListFilterView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        sendActions(for: .valueChanged)
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        sendActions(for: .valueChanged)
    }
}

fileprivate final class ItemCell: UICollectionViewCell {
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = CompactListFilterView.Style.itemNormalFont
        label.textColor = CompactListFilterView.Style.itemNormalTextColor
        return label
    }()

    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? CompactListFilterView.Style.itemSelectedBackgroundColor : CompactListFilterView.Style.itemNormalBackgroundColor
            layer.borderColor = isSelected ? CompactListFilterView.Style.itemSelectedBackgroundColor.cgColor : CompactListFilterView.Style.itemBorderColor.cgColor
            titleLabel.font = isSelected ? CompactListFilterView.Style.itemSelectedFont : CompactListFilterView.Style.itemNormalFont
            titleLabel.textColor = isSelected ? CompactListFilterView.Style.itemSelectedTextColor : CompactListFilterView.Style.itemNormalTextColor
        }
    }

    var value: String = "" {
        didSet {
            titleLabel.text = value
            accessibilityValue = value
        }
    }

    var accessibilityValuePrefix: String? {
        didSet {
            accessibilityValue = "\(accessibilityValuePrefix ?? "") \(value)"
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        isAccessibilityElement = true

        contentView.addSubview(titleLabel)
        titleLabel.fillInSuperview()

        layer.cornerRadius = frame.width / 4
        layer.borderWidth = CompactListFilterView.Style.itemBorderWidth
        layer.borderColor = CompactListFilterView.Style.itemBorderColor.cgColor
    }
}
