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

    private var selectionTitles = [String]()
    private var isValid = false
    private var isCollapsed = false

    private lazy var collectionViewLayout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = .mediumSpacing
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .milk
        collectionView.isScrollEnabled = false
        collectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = false
        collectionView.register(SelectionTagViewCell.self)
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

        isCollapsed = false
        collectionView.reloadData()
        collectionView.layoutIfNeeded()

        if collectionView.contentSize.width > collectionView.frame.width {
            isCollapsed = true
            collectionView.reloadData()
            collectionViewLayout.invalidateLayout()
        }
    }

    private func setup() {
        addSubview(collectionView)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 44),

            collectionView.centerYAnchor.constraint(equalTo: centerYAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: SelectionTagViewCell.height),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
        ])
    }

    private func title(at indexPath: IndexPath) -> String {
        return isCollapsed ? selectionTitles.joinedTitles : selectionTitles[indexPath.item]
    }
}

// MARK: - UICollectionViewDataSource

extension SelectionTagsContainerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard !selectionTitles.isEmpty else {
            return 0
        }

        return isCollapsed ? 1 : selectionTitles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(SelectionTagViewCell.self, for: indexPath)

        cell.configure(withTitle: title(at: indexPath), isValid: isValid)
        cell.contentView.transform = CGAffineTransform(scaleX: -1, y: 1)
        cell.delegate = self

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SelectionTagsContainerView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = SelectionTagViewCell.width(for: title(at: indexPath))
        let itemWidth = min(collectionView.bounds.width, cellWidth)
        return CGSize(width: itemWidth, height: SelectionTagViewCell.height)
    }
}

// MARK: - FilterTagViewDelegate

extension SelectionTagsContainerView: SelectionTagViewCellDelegate {
    func selectionTagViewCellDidSelectRemove(_ cell: SelectionTagViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }

        if isCollapsed {
            selectionTitles.removeAll()
        } else {
            selectionTitles.remove(at: indexPath.item)
        }

        collectionView.deleteItems(at: [indexPath])

        if isCollapsed {
            delegate?.selectionTagsContainerViewDidRemoveAllTags(self)
        } else {
            delegate?.selectionTagsContainerView(self, didRemoveTagAt: indexPath.item)
        }
    }
}

// MARK: - Private extensions

private extension Array where Element == String {
    var joinedTitles: String {
        let string = joined(separator: ", ")
        return count > 1 ? "(\(count)) \(string)" : string
    }
}
