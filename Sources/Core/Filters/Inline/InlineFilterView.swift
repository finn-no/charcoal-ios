//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol InlineFilterViewDelegate: class {
    func inlineFilterView(_ inlineFilterview: InlineFilterView, didTapExpandableSegment segment: Segment)
}

final class InlineFilterView: UIView {

    // MARK: - Public Properties

    weak var delegate: InlineFilterViewDelegate?

    // MARK: - Private properties

    private var filter: Filter?
    private var vertical: String?
    private let selectionStore: FilterSelectionStore

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

    init(selectionStore: FilterSelectionStore) {
        self.selectionStore = selectionStore
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func configure(with filter: Filter, vertical: String? = nil) {
        self.filter = filter
        self.vertical = vertical
        setupItems()
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
        guard let index = segments.firstIndex(of: segment), let subfilter = filter?.subfilter(at: index) else {
            return
        }

        selectionStore.removeValues(for: subfilter)

        for index in segment.selectedItems {
            if let subfilter = subfilter.subfilter(at: index) {
                selectionStore.setValue(from: subfilter)
            }
        }
    }

    @objc func handleExpandedSegment(segment: Segment) {
        guard segment.isExpandable else { return }
        delegate?.inlineFilterView(self, didTapExpandableSegment: segment)
    }

    func setupItems() {
        segments = []

        if let vertical = vertical {
            let segment = Segment(titles: [vertical], isExpandable: true)
            segment.addTarget(self, action: #selector(handleExpandedSegment(segment:)), for: .touchUpInside)
            segments.append(segment)
        }

        if let filter = filter {
            let segmentTitles = filter.subfilters.map({ $0.subfilters.map({ $0.title }) })

            for (index, titles) in segmentTitles.enumerated() {
                let segment = Segment(titles: titles)

                if let subFilter = filter.subfilter(at: index) {
                    let selectedItems = subFilter.subfilters.enumerated().compactMap { (index, filter) -> Int? in
                        self.selectionStore.isSelected(filter) == true ? index : nil
                    }

                    segment.selectedItems = selectedItems
                }

                segment.addTarget(self, action: #selector(handleValueChanged(segment:)), for: .valueChanged)
                segments.append(segment)
            }

            collectionView.reloadData()
        }
    }
}
