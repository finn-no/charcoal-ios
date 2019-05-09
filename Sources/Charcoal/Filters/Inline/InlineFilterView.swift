//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol InlineFilterViewDelegate: AnyObject {
    func inlineFilterView(_ inlineFilteView: InlineFilterView, didChange segment: Segment, at index: Int)
}

final class InlineFilterView: UIView {
    // MARK: - Internal properties

    weak var delegate: InlineFilterViewDelegate?

    override var intrinsicContentSize: CGSize {
        return CGSize(width: collectionView.bounds.width, height: InlineSegmentCell.cellHeight + .mediumLargeSpacing)
    }

    // MARK: - Private properties

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

    func configure(withTitles titles: [[String]], selectedItems: [[Int]]) {
        segments = []

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

    func slideInWithFade() {
        collectionView.setContentOffset(CGPoint(x: -120, y: 0), animated: false)
        collectionView.alpha = 0

        UIView.animate(
            withDuration: 0.9,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
                self.collectionView.alpha = 1.0
            }
        )
    }
}

// MARK: - Collection view data source

extension InlineFilterView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return segments.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(InlineSegmentCell.self, for: indexPath)
        cell.segment = segments[indexPath.item]
        return cell
    }
}

extension InlineFilterView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let segmentSize = segments[indexPath.item].intrinsicContentSize
        return CGSize(width: segmentSize.width, height: InlineSegmentCell.cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .mediumSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .mediumSpacing
    }
}

// MARK: - Private methods

private extension InlineFilterView {
    func setup() {
        addSubview(collectionView)
        collectionView.fillInSuperview(insets: UIEdgeInsets(top: .mediumSpacing, leading: 0, bottom: -.mediumSpacing, trailing: 0))
        collectionView.heightAnchor.constraint(equalToConstant: InlineSegmentCell.cellHeight).isActive = true
    }

    @objc func handleValueChanged(segment: Segment) {
        guard let index = segments.firstIndex(of: segment) else {
            return
        }

        UISelectionFeedbackGenerator().selectionChanged()
        delegate?.inlineFilterView(self, didChange: segment, at: index)
    }
}
