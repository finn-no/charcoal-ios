//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

final class GridFilterViewController: FilterViewController {
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .milk
        collectionView.allowsMultipleSelection = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: .mediumLargeSpacing, left: 27, bottom: 0, right: 27)
        collectionView.register(GridFilterCell.self)
        return collectionView
    }()

    private let filter: Filter

    // MARK: - Init

    init(filter: Filter, selectionStore: FilterSelectionStore) {
        self.filter = filter
        super.init(title: filter.title, selectionStore: selectionStore)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        bottomButton.buttonTitle = "applyButton".localized()
        showBottomButton(false, animated: false)
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()

        for (index, filter) in filter.subfilters.enumerated() where selectionStore.isSelected(filter) {
            collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .left)
        }
    }

    // MARK: - Setup

    private func setup() {
        view.insertSubview(collectionView, belowSubview: bottomButton)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomButton.topAnchor),
        ])
    }
}

// MARK: - UICollectionViewDataSource

extension GridFilterViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filter.subfilters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(GridFilterCell.self, for: indexPath)
        let currentFilter = filter.subfilters[indexPath.row]
        cell.configure(withTitle: currentFilter.title, accessibilityPrefix: filter.title)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension GridFilterViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow: CGFloat = 5
        let side = (collectionView.frame.width / numberOfItemsPerRow) - .mediumSpacing

        return CGSize(width: side, height: side)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .mediumSpacing
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentFilter = filter.subfilters[indexPath.row]

        UISelectionFeedbackGenerator().selectionChanged()
        selectionStore.setValue(from: currentFilter)
        showBottomButtonIfNeeded()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
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
