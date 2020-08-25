//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

public final class GridFilterViewController: FilterViewController {
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = Theme.mainBackground
        collectionView.allowsMultipleSelection = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: .spacingM, left: edgeInset, bottom: 0, right: edgeInset)
        collectionView.register(GridFilterCell.self)
        return collectionView
    }()

    private let edgeInset: CGFloat = 27
    private let filter: Filter

    private lazy var collectionViewBottomAnchorConstraint: NSLayoutConstraint = {
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    }()

    // MARK: - Init

    public init(filter: Filter, selectionStore: FilterSelectionStore) {
        self.filter = filter
        super.init(title: filter.title, selectionStore: selectionStore)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    public override func viewDidLoad() {
        super.viewDidLoad()
        bottomButton.buttonTitle = "applyButton".localized()
        showBottomButton(false, animated: false)
        setup()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()

        for (index, filter) in filter.subfilters.enumerated() where selectionStore.isSelected(filter) {
            collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .left)
        }
    }

    public override func showBottomButton(_ show: Bool, animated: Bool) {
        super.showBottomButton(show, animated: animated)

        if show {
            collectionViewBottomAnchorConstraint.constant = -bottomButton.frame.height
            view.layoutIfNeeded()
        }
    }

    // MARK: - Setup

    private func setup() {
        view.insertSubview(collectionView, belowSubview: bottomButton)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionViewBottomAnchorConstraint,
        ])
    }
}

// MARK: - UICollectionViewDataSource

extension GridFilterViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filter.subfilters.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(GridFilterCell.self, for: indexPath)
        let currentFilter = filter.subfilters[indexPath.row]
        cell.configure(withTitle: currentFilter.title, accessibilityPrefix: filter.title)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension GridFilterViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow: CGFloat = 5
        let side = ((collectionView.frame.width - edgeInset * 2) / numberOfItemsPerRow) - .spacingS

        return CGSize(width: side, height: side)
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .spacingS
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentFilter = filter.subfilters[indexPath.row]

        UISelectionFeedbackGenerator().selectionChanged()
        selectionStore.setValue(from: currentFilter)
        showBottomButtonIfNeeded()
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let currentFilter = filter.subfilters[indexPath.row]

        UISelectionFeedbackGenerator().selectionChanged()
        selectionStore.removeValues(for: currentFilter)
        showBottomButtonIfNeeded()
    }

    private func showBottomButtonIfNeeded() {
        if !isShowingBottomButton {
            showBottomButton(true, animated: true)
        }
    }
}
