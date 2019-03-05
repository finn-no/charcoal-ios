//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol RootFilterViewControllerDelegate: class {
    func rootFilterViewController(_ viewController: RootFilterViewController, didSelectVerticalAt index: Int)
}

final class RootFilterViewController: FilterViewController {

    // MARK: - Internal properties

    var verticals: [Vertical]?

    weak var rootDelegate: (RootFilterViewControllerDelegate & FilterViewControllerDelegate)? {
        didSet { delegate = rootDelegate }
    }

    weak var freeTextFilterDelegate: FreeTextFilterDelegate?
    weak var freeTextFilterDataSource: FreeTextFilterDataSource?

    // MARK: - Private properties

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FreeTextFilterCell.self)
        tableView.register(CCInlineFilterCell.self)
        tableView.register(RootFilterCell.self)
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var resetButton: UIBarButtonItem = {
        let action = #selector(handleResetButtonTap)
        let button = UIBarButtonItem(title: "reset".localized(), style: .plain, target: self, action: action)
        button.setTitleTextAttributes([.font: UIFont.title4])
        return button
    }()

    private var freeTextFilterViewController: FreeTextFilterViewController?
    private var filter: Filter
    private let config: FilterConfiguration

    // MARK: - Init

    init(filter: Filter, config: FilterConfiguration, selectionStore: FilterSelectionStore) {
        self.filter = filter
        self.config = config
        super.init(title: filter.title, selectionStore: selectionStore)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = resetButton

        showBottomButton(true, animated: false)
        bottomButton.buttonTitle = String(format: "show_x_hits_button_title".localized(), filter.numberOfResults)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomButton.height, right: 0)
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Setup

    func set(filter: Filter, verticals: [Vertical]?) {
        self.filter = filter
        self.verticals = verticals
        navigationItem.title = filter.title
        bottomButton.buttonTitle = String(format: "show_x_hits_button_title".localized(), filter.numberOfResults)
        tableView.reloadData()
    }

    private func setup() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - Actions

    @objc private func handleResetButtonTap() {
        selectionStore.removeValues(for: filter)
        tableView.reloadData()
    }
}

extension RootFilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filter.subfilters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentFilter = filter.subfilters[indexPath.row]

        switch currentFilter.kind {
        case .search:
            freeTextFilterViewController =
                freeTextFilterViewController ??
                FreeTextFilterViewController(filter: currentFilter, selectionStore: selectionStore)

            freeTextFilterViewController?.delegate = self
            freeTextFilterViewController?.filterDelegate = freeTextFilterDelegate
            freeTextFilterViewController?.filterDataSource = freeTextFilterDataSource

            let cell = tableView.dequeue(FreeTextFilterCell.self, for: indexPath)
            cell.configure(with: freeTextFilterViewController!.searchBar)
            return cell
        case .inline:
            let cell = tableView.dequeue(CCInlineFilterCell.self, for: indexPath)
            cell.delegate = self
            let segmentTitles = currentFilter.subfilters.map({ $0.subfilters.map({ $0.title }) })
            let vertical = verticals?.first(where: { $0.isCurrent })
            cell.configure(with: segmentTitles, vertical: vertical?.title)
            return cell
        default:
            let titles = selectionStore.titles(for: currentFilter)
            let isValid = selectionStore.isValid(currentFilter)
            let cell = tableView.dequeue(RootFilterCell.self, for: indexPath)

            cell.delegate = self
            cell.configure(withTitle: currentFilter.title, selectionTitles: titles, isValid: isValid, style: currentFilter.style)

            let exclusiveFilters = config.mutuallyExclusiveFilters(for: currentFilter.key)
            cell.isEnabled = !selectionStore.hasSelectedSubfilters(for: filter, where: {
                exclusiveFilters.contains($0.key)
            })

            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension RootFilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilter = filter.subfilters[indexPath.row]
        switch selectedFilter.kind {
        case .search, .inline:
            return
        default:
            delegate?.filterViewController(self, didSelectFilter: selectedFilter)
        }
    }
}

// MARK: - RootFilterCellDelegate

extension RootFilterViewController: RootFilterCellDelegate {
    func rootFilterCell(_ cell: RootFilterCell, didRemoveTagAt index: Int) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        let currentFilter = filter.subfilters[indexPath.row]
        let selectedSubfilters = selectionStore.selectedSubfilters(for: currentFilter)

        selectionStore.removeValues(for: selectedSubfilters[index])
        reloadCellsWithExclusiveFilters(for: currentFilter)
    }

    func rootFilterCellDidRemoveAllTags(_ cell: RootFilterCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        let currentFilter = filter.subfilters[indexPath.row]

        selectionStore.removeValues(for: currentFilter)
        reloadCellsWithExclusiveFilters(for: currentFilter)
    }

    private func reloadCellsWithExclusiveFilters(for filter: Filter) {
        let exclusiveFilters = config.mutuallyExclusiveFilters(for: filter.key)

        let indexPathsToReload = self.filter.subfilters.enumerated().compactMap({ index, subfilter in
            return exclusiveFilters.contains(subfilter.key) ? IndexPath(row: index, section: 0) : nil
        })

        tableView.reloadRows(at: indexPathsToReload, with: .none)
    }
}

// MARK: - CCInlineFilterViewDelegate

extension RootFilterViewController: InlineFilterViewDelegate {
    func inlineFilterView(_ inlineFilterView: InlineFilterView, didChangeSegment segment: Segment, at index: Int) {
        guard let subfilter = filter.subfilter(at: index) else { return }

        selectionStore.removeValues(for: subfilter)

        for index in segment.selectedItems {
            if let subfilter = subfilter.subfilter(at: index) {
                selectionStore.setValue(from: subfilter)
            }
        }
    }

    func inlineFilterView(_ inlineFilterview: InlineFilterView, didTapExpandableSegment segment: Segment) {
        guard let verticals = verticals else { return }
        let verticalViewController = VerticalListViewController(verticals: verticals)
        verticalViewController.popoverTransitionDelegate.willDismissPopoverHandler = { _ in segment.selectedItems = [] }
        verticalViewController.popoverTransitionDelegate.sourceView = segment
        verticalViewController.delegate = self
        present(verticalViewController, animated: true, completion: nil)
    }
}

// MARK: - VerticalListViewControllerDelegate

extension RootFilterViewController: VerticalListViewControllerDelegate {
    func verticalListViewController(_ verticalViewController: VerticalListViewController, didSelectVerticalAtIndex index: Int) {
        verticalViewController.dismiss(animated: false)
        rootDelegate?.rootFilterViewController(self, didSelectVerticalAt: index)
    }
}

// MARK: - FreeTextFilterViewControllerDelegate

extension RootFilterViewController: FreeTextFilterViewControllerDelegate {
    func freeTextFilterViewControllerWillBeginEditing(_ viewController: FreeTextFilterViewController) {
        add(viewController)
    }

    func freeTextFilterViewControllerWillEndEditing(_ viewController: FreeTextFilterViewController) {
        viewController.remove()
        tableView.reloadData()
    }
}
