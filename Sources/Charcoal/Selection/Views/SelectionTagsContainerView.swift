//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit
import Warp

protocol SelectionTagsContainerViewDelegate: AnyObject {
    func selectionTagsContainerView(_ view: SelectionTagsContainerView, didRemoveTagAt index: Int)
    func selectionTagsContainerViewDidRemoveAllTags(_ view: SelectionTagsContainerView)
}

final class SelectionTagsContainerView: UIView {
    weak var delegate: SelectionTagsContainerViewDelegate?

    private var selectionTitles = [SelectionTitle]()
    private var isValid = false
    private var isCollapsed = false

    private lazy var collectionViewLayout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Warp.Spacing.spacing100
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = CollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
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

    func configure(with selectionTitles: [SelectionTitle], isValid: Bool) {
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

            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.centerYAnchor.constraint(equalTo: centerYAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: SelectionTagViewCell.height),
        ])
    }

    private func title(at indexPath: IndexPath) -> SelectionTitle {
        return isCollapsed ? selectionTitles.joinedTitle : selectionTitles[indexPath.item]
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
        var cellWidth = SelectionTagViewCell.width(for: title(at: indexPath).value)
        cellWidth = min(collectionView.bounds.width, cellWidth)
        cellWidth = max(cellWidth, SelectionTagViewCell.minWidth)
        return CGSize(width: cellWidth, height: SelectionTagViewCell.height)
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

private final class CollectionView: UICollectionView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return hitView == self ? nil : hitView
    }
}

// MARK: - Private extensions

private extension Array where Element == SelectionTitle {
    var joinedTitle: SelectionTitle {
        let prefix = count > 1 ? "(\(count)) " : ""

        return SelectionTitle(
            value: prefix + map { $0.value }.joined(separator: ", "),
            accessibilityLabel: map { $0.accessibilityLabel }.joined(separator: ", ")
        )
    }
}
