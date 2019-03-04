//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol SelectionTagsContainerViewDelegate: AnyObject {
    func selectionTagsContainerView(_ view: SelectionTagsContainerView, didRemoveTagAt index: Int)
    func selectionTagsContainerViewDidRemoveAllTags(_ view: SelectionTagsContainerView)
}

final class SelectionTagsContainerView: UIView {
    weak var delegate: SelectionTagsContainerViewDelegate?
    private var isValid = false
    private var multiTags = false
    private var selectionTitles = [String]()

    // MARK: - Private properties

    private lazy var collectionViewLayout: CollectionViewFlowLayout = {
        let layout = CollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 50, height: 30)
        layout.minimumLineSpacing = .mediumSpacing
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.clipsToBounds = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .milk
        collectionView.register(SelectionTagViewCell.self)
        collectionView.semanticContentAttribute = .forceRightToLeft
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Setup

    func configure(with selectionTitles: [String], isValid: Bool) {
        self.selectionTitles = selectionTitles
        self.isValid = isValid

        multiTags = false
        collectionView.reloadData()
        collectionView.layoutIfNeeded()

        if collectionView.contentSize.width > collectionView.frame.width {
            multiTags = true
            collectionView.reloadData()
            collectionViewLayout.invalidateLayout()
        }
    }

    private func setup() {
        addSubview(collectionView)

        let tagViewHeight: CGFloat = 30

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 44),

            collectionView.centerYAnchor.constraint(equalTo: centerYAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: tagViewHeight),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }
}

extension SelectionTagsContainerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard !selectionTitles.isEmpty else {
            return 0
        }

        return multiTags ? 1 : selectionTitles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(SelectionTagViewCell.self, for: indexPath)
        let title = multiTags ? selectionTitles.joinedTitles : selectionTitles[indexPath.item]
        cell.selectionView.configure(withTitle: title, isValid: isValid)
        return cell
    }
}

extension SelectionTagsContainerView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectionTitles.remove(at: indexPath.item)
        collectionView.deleteItems(at: [indexPath])
        // setNeedsLayout()
        // delegate?.selectionView(self, didRemoveItemAt: indexPath.item)
    }
}

// MARK: - Private types

private class SelectionTagViewCell: UICollectionViewCell {
    private(set) lazy var selectionView = SelectionTagView(withAutoLayout: true)

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(selectionView)
        selectionView.fillInSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - FilterTagViewDelegate

extension SelectionTagsContainerView: SelectionTagViewDelegate {
    func selectionTagViewDidSelectRemove(_ view: SelectionTagView) {
//        if view === multiTagView {
//            delegate?.selectionTagsContainerViewDidRemoveAllTags(self)
//        } else if let index = tagsStackView.arrangedSubviews.index(of: view) {
//            delegate?.selectionTagsContainerView(self, didRemoveTagAt: index)
//        }
    }
}

// MARK: - Private extensions

private extension Array where Element == String {
    var joinedTitles: String {
        let string = joined(separator: ", ")
        return count > 1 ? "(\(count)) \(string)" : string
    }
}

final class CollectionViewFlowLayout: UICollectionViewFlowLayout {
    // Don't forget to use this class in your storyboard (or code, .xib etc)

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath) else {
            return nil
        }

        guard let collectionView = collectionView else {
            return attributes
        }

        if attributes.bounds.size.width > collectionView.bounds.width {
            attributes.bounds.size.width = collectionView.bounds.width
            attributes.frame.origin.x = 0
        }

        return attributes
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let allAttributes = super.layoutAttributesForElements(in: rect)
        return allAttributes?.compactMap { attributes in
            switch attributes.representedElementCategory {
            case .cell: return layoutAttributesForItem(at: attributes.indexPath)
            default: return attributes
            }
        }
    }
}
