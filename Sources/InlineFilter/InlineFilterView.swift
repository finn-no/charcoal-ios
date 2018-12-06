//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol InlineFilterViewDelegate: class {
    func inlineFilterView(_ inlineFilterView: InlineFilterView, didTapExpandableSegment segment: Segment)
}

public class InlineFilterView: UICollectionView {

    // MARK: - Public properties

    public var selectionDataSource: FilterSelectionDataSource?
    public weak var inlineFilterDelegate: InlineFilterViewDelegate?

    // MARK: - Private properties

    private var segments: [Segment] = []
    private let preferences: [PreferenceFilterInfoType]
    private let verticals: [Vertical]

    // MARK: - Setup

    public init(verticals: [Vertical] = [], preferences: [PreferenceFilterInfoType]) {
        self.verticals = verticals
        self.preferences = preferences
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = .mediumLargeSpacing
        layout.estimatedItemSize = CGSize(width: 300, height: InlineFilterViewCell.cellHeight)
        super.init(frame: .zero, collectionViewLayout: layout)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Collection view data source

extension InlineFilterView: UICollectionViewDataSource {
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

private extension InlineFilterView {
    func setup() {
        backgroundColor = .milk
        showsHorizontalScrollIndicator = false
        dataSource = self
        register(InlineFilterViewCell.self)
        setupItems()
    }

    @objc func handleValueChanged(segment: Segment) {
        guard let index = segments.firstIndex(of: segment) else { return }
        let hasVerticals = !verticals.isEmpty ? 1 : 0
        let preference = preferences[index - hasVerticals]
        let values = segment.selectedItems.map { index -> String in
            return preference.values[index].value
        }
        if values.isEmpty {
            selectionDataSource?.clearAll(for: preference)
        } else {
            selectionDataSource?.setValue(values, for: preference)
        }
    }

    @objc func handleSegmentPressed(segment: Segment) {
        inlineFilterDelegate?.inlineFilterView(self, didTapExpandableSegment: segment)
    }

    func setupItems() {
        if let vertical = verticals.first(where: { $0.isCurrent }) {
            let segment = Segment(titles: [vertical.title], isExpandable: true)
            segment.addTarget(self, action: #selector(handleSegmentPressed(segment:)), for: .touchUpInside)
            segments.append(segment)
        }

        for preference in preferences {
            let titles = preference.values.map { $0.title }
            let segment = Segment(titles: titles)
            segment.addTarget(self, action: #selector(handleValueChanged(segment:)), for: .valueChanged)
            segments.append(segment)
        }
    }
}
