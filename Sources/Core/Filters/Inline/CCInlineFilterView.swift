//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol CCInlineFilterViewDelegate: class {
    func inlineFilterView(_ inlineFilterView: CCInlineFilterView, didChangeSegment segment: Segment, at index: Int)
    func inlineFilterView(_ inlineFilterview: CCInlineFilterView, didTapExpandableSegment segment: Segment)
}

class CCInlineFilterView: UIView {

    // MARK: - Public Properties

    var vertical: String?

    var segmentTitles: [[String]] = [] {
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
        let cell = collectionView.dequeue(InlineSegmentCell.self, for: indexPath)
        cell.segment = segments[indexPath.item]
        return cell
    }
}

// MARK: - Private methods

private extension CCInlineFilterView {
    func setup() {
        addSubview(collectionView)
        collectionView.fillInSuperview()
        collectionView.heightAnchor.constraint(equalToConstant: InlineSegmentCell.cellHeight).isActive = true
    }

    @objc func handleValueChanged(segment: Segment) {
        guard let index = segments.firstIndex(of: segment) else {
            return
        }

        delegate?.inlineFilterView(self, didChangeSegment: segment, at: index)
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

        for titles in segmentTitles {
            let segment = Segment(titles: titles)
            segment.addTarget(self, action: #selector(handleValueChanged(segment:)), for: .valueChanged)
            segments.append(segment)
        }
        collectionView.reloadData()
    }
}
