//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol InlineFilterViewDelegate: class {
    func inlineFilterView(_ inlineFilteView: InlineFilterView, didChange segment: Segment, at index: Int)
    func inlineFilterView(_ inlineFilterview: InlineFilterView, didTapExpandableSegment segment: Segment)
}

final class InlineFilterView: UIView {

    // MARK: - Public Properties

    weak var delegate: InlineFilterViewDelegate?

    // MARK: - Private properties

    private var vertical: String?
    private var segmentTitles: [[String]] = []
    private var segments: [Segment] = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = .mediumLargeSpacing
        layout.estimatedItemSize = CGSize(width: 300, height: InlineSegmentCell.cellHeight)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .milk
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, leading: .mediumLargeSpacing, bottom: 0, trailing: 0)
        collectionView.register(InlineSegmentCell.self)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func configure(withTitles titles: [[String]], vertical: String? = nil, selectedItems: [[Int]]) {
        segmentTitles = titles
        self.vertical = vertical
        setupItems(withSelected: selectedItems)
    }
}

// MARK: - Collection view data source

extension InlineFilterView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return segments.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(InlineSegmentCell.self, for: indexPath)
        cell.segment = segments[indexPath.item]
        return cell
    }
}

// MARK: - Private methods

private extension InlineFilterView {
    func setup() {
        addSubview(collectionView)
        collectionView.fillInSuperview()
        collectionView.heightAnchor.constraint(equalToConstant: InlineSegmentCell.cellHeight).isActive = true
    }

    @objc func handleValueChanged(segment: Segment) {
        guard let index = segments.firstIndex(of: segment) else {
            return
        }

        delegate?.inlineFilterView(self, didChange: segment, at: index)
    }

    @objc func handleExpandedSegment(segment: Segment) {
        guard segment.isExpandable else { return }
        delegate?.inlineFilterView(self, didTapExpandableSegment: segment)
    }

    func setupItems(withSelected selectedItems: [[Int]]) {
        segments = []

        if let vertical = vertical {
            let segment = Segment(titles: [vertical], isExpandable: true)
            segment.addTarget(self, action: #selector(handleExpandedSegment(segment:)), for: .touchUpInside)
            segments.append(segment)
        }

        for (index, titles) in segmentTitles.enumerated() {
            let segment = Segment(titles: titles)
            segment.selectedItems = selectedItems[index]
            segment.addTarget(self, action: #selector(handleValueChanged(segment:)), for: .valueChanged)
            segments.append(segment)
        }

        collectionView.reloadData()
    }
}
