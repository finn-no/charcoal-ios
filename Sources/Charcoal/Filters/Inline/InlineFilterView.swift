//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol InlineFilterViewDelegate: class {
    func inlineFilterView(_ inlineFilteView: InlineFilterView, didChange segment: Segment, at index: Int)
    func inlineFilterView(_ inlineFilterview: InlineFilterView, didTapExpandableSegment segment: Segment)
}

final class InlineFilterView: UIView {
    private enum Section: Int, CaseIterable {
        case vertical
        case filters
    }

    // MARK: - Public Properties

    weak var delegate: InlineFilterViewDelegate?

    // MARK: - Private properties

    private var vertical: Segment?
    private var segments: [Segment] = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .milk
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 0, leading: .mediumLargeSpacing, bottom: 0, trailing: .mediumLargeSpacing)
        collectionView.register(InlineSegmentCell.self)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func configure(withTitles titles: [[String]], verticalTitle: String? = nil, selectedItems: [[Int]]) {
        vertical = nil
        segments = []

        if let verticalTitle = verticalTitle {
            let segment = Segment(titles: [verticalTitle], isExpandable: true, accessibilityPrefix: "vertical".localized())
            segment.addTarget(self, action: #selector(handleExpandedSegment(segment:)), for: .touchUpInside)
            vertical = segment
        }

        for (index, titles) in titles.enumerated() {
            let segment = Segment(titles: titles)
            segment.selectedItems = selectedItems[index]
            segment.addTarget(self, action: #selector(handleValueChanged(segment:)), for: .valueChanged)
            segments.append(segment)
        }

        collectionView.reloadData()
    }

    func resetContentOffset() {
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
    }
}

// MARK: - Collection view data source

extension InlineFilterView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }

        switch section {
        case .vertical:
            return vertical != nil ? 1 : 0
        case .filters:
            return segments.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section) else { fatalError("InlineFilter not configured correctly") }
        let cell = collectionView.dequeue(InlineSegmentCell.self, for: indexPath)

        switch section {
        case .vertical:
            cell.segment = vertical
        case .filters:
            cell.segment = segments[indexPath.item]
        }

        return cell
    }
}

extension InlineFilterView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let section = Section(rawValue: indexPath.section) else { return .zero }

        let segmentSize: CGSize

        switch section {
        case .vertical:
            segmentSize = vertical?.intrinsicContentSize ?? .zero
        case .filters:
            segmentSize = segments[indexPath.item].intrinsicContentSize
        }

        return CGSize(width: segmentSize.width, height: InlineSegmentCell.cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let section = Section(rawValue: section) else { return .zero }

        switch section {
        case .vertical:
            return .zero
        case .filters:
            let spacing: CGFloat = vertical == nil ? 0 : .mediumSpacing
            return UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: 0)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .mediumSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .mediumSpacing
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
}
