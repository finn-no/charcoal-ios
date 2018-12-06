//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol InlineFilterViewDelegate: class {
    func inlineFilterView(_ inlineFilterView: InlineFilterView, didTapExpandableSegment segment: Segment)
}

public class InlineFilterView: UICollectionView {
    public let preferences: [PreferenceFilterInfoType]
    public var verticals: [Vertical]?
    public var selectionDataSource: FilterSelectionDataSource?
    public weak var inlineDelegate: InlineFilterViewDelegate?

    private var segments: [Segment] = []

    public init(verticals: [Vertical]? = nil, preferences: [PreferenceFilterInfoType]) {
        self.verticals = verticals
        self.preferences = preferences
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 300, height: 38)
        super.init(frame: .zero, collectionViewLayout: layout)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InlineFilterView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return segments.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(InlineFilterViewCell.self, for: indexPath)
        print(indexPath, cell)
        cell.segment = segments[indexPath.item]
        return cell
    }
}

extension InlineFilterView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

private extension InlineFilterView {
    func setup() {
        backgroundColor = .milk
        showsHorizontalScrollIndicator = false
        dataSource = self
        delegate = self
        contentInset = UIEdgeInsets(top: 0, leading: .mediumLargeSpacing, bottom: 0, trailing: .mediumLargeSpacing)
        register(InlineFilterViewCell.self)
        setupItems()
    }

    var hasVerticals: Int {
        return verticals != nil ? 1 : 0
    }

    @objc func handleValueChanged(segment: Segment) {
        guard let index = segments.firstIndex(of: segment) else { return }
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
        inlineDelegate?.inlineFilterView(self, didTapExpandableSegment: segment)
    }

    func setupItems() {
        if let vertical = verticals?.first {
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
