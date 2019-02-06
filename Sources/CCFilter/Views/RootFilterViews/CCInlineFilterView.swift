//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol CCInlineFilterViewDelegate: class {
    func inlineFilterViewDidChangeValue(_ inlineFilterView: CCInlineFilterView)
}

class CCInlineFilterView: UIView {

    // MARK: - Public Properties

    var filterNode: CCFilterNode? {
        didSet {
            setupItems()
        }
    }

    weak var delegate: CCInlineFilterViewDelegate?

    // MARK: - Private properties

    private var segments: [Segment] = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = .mediumLargeSpacing
        layout.estimatedItemSize = CGSize(width: 300, height: InlineFilterViewCell.cellHeight)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .milk
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, leading: .mediumLargeSpacing, bottom: 0, trailing: 0)
        collectionView.register(InlineFilterViewCell.self)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Collection view data source

extension CCInlineFilterView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return segments.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(InlineFilterViewCell.self, for: indexPath)
        cell.segment = segments[indexPath.item]
        return cell
    }
}

// MARK: - Private methods

private extension CCInlineFilterView {
    func setup() {
        addSubview(collectionView)
        collectionView.fillInSuperview()
    }

    @objc func handleValueChanged(segment: Segment) {
        guard let children = filterNode?.children, let index = segments.firstIndex(of: segment) else { return }
        let node = children[index]
        node.children.forEach { $0.isSelected = false }
        segment.selectedItems.forEach { node.children[$0].isSelected = true }
        delegate?.inlineFilterViewDidChangeValue(self)
    }

    func setupItems() {
        segments = []
        guard let nodes = filterNode?.children else { return }
        for node in nodes {
            let titles = node.children.map { $0.title }
            let segment = Segment(titles: titles)
            segment.addTarget(self, action: #selector(handleValueChanged(segment:)), for: .valueChanged)
            segments.append(segment)
        }
        collectionView.reloadData()
    }
}
