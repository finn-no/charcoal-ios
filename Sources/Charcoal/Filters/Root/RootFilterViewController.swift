//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol RootFilterViewControllerDelegate: class {
    func rootFilterViewControllerDidResetAllFilters(_ viewController: RootFilterViewController)
    func rootFilterViewController(_ viewController: RootFilterViewController, didRemoveFilter filter: Filter)
    func rootFilterViewController(_ viewController: RootFilterViewController, didSelectInlineFilter filter: Filter)
    func rootFilterViewController(_ viewController: RootFilterViewController, didSelectFreeTextFilter filter: Filter)
    func rootFilterViewController(_ viewController: RootFilterViewController, didSelectVertical vertical: Vertical)
}

final class RootFilterViewController: FilterViewController {
    enum Section: Int, CaseIterable {
        case freeText, inline, rootFilters
    }

    // MARK: - Internal properties

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
        tableView.register(InlineFilterCell.self)
        tableView.register(RootFilterCell.self)
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var resetButton: UIBarButtonItem = {
        let action = #selector(handleResetButtonTap)
        let button = UIBarButtonItem(title: "reset".localized(), style: .plain, target: self, action: action)
        button.setTitleTextAttributes([.font: UIFont.bodyStrong])
        return button
    }()

    private var freeTextFilterViewController: FreeTextFilterViewController?
    private var shouldResetInlineFilterCell = false

    // MARK: - Filter

    private var filterContainer: FilterContainer

    // MARK: - Init

    init(filterContainer: FilterContainer, selectionStore: FilterSelectionStore) {
        self.filterContainer = filterContainer
        super.init(title: "rootTitle".localized(), selectionStore: selectionStore)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = resetButton

        showBottomButton(true, animated: false)
        updateBottomButtonTitle()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Public

    func reloadFilters() {
        tableView.reloadData()
    }

    // MARK: - Setup

    func set(filterContainer: FilterContainer) {
        self.filterContainer = filterContainer
        updateBottomButtonTitle()
        tableView.reloadData()
    }

    private func setup() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomButton.topAnchor),
        ])
    }

    private func updateBottomButtonTitle() {
        let localizedString = String(format: "showResultsButton".localized(), filterContainer.numberOfResults)
        let title = localizedString.replacingOccurrences(
            of: "\(filterContainer.numberOfResults)",
            with: filterContainer.numberOfResults.decimalFormatted
        )

        bottomButton.buttonTitle = title
    }

    // MARK: - Actions

    @objc private func handleResetButtonTap() {
        selectionStore.removeValues(for: filterContainer.allFilters)
        rootDelegate?.rootFilterViewControllerDidResetAllFilters(self)
        freeTextFilterViewController?.searchBar.text = nil
        shouldResetInlineFilterCell = true

        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        tableView.layoutIfNeeded()
        tableView.reloadData()
    }
}

extension RootFilterViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }

        switch section {
        case .freeText:
            return filterContainer.freeTextFilter != nil ? 1 : 0
        case .inline:
            return filterContainer.inlineFilter != nil ? 1 : 0
        case .rootFilters:
            return filterContainer.rootFilters.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { fatalError("Apple screwed up!") }

        switch section {
        case .freeText:
            let cell = tableView.dequeue(FreeTextFilterCell.self, for: indexPath)

            if let freeTextFilter = filterContainer.freeTextFilter, freeTextFilterViewController == nil {
                freeTextFilterViewController = FreeTextFilterViewController(filter: freeTextFilter, selectionStore: selectionStore)
            }

            freeTextFilterViewController?.delegate = self
            freeTextFilterViewController?.filterDelegate = freeTextFilterDelegate
            freeTextFilterViewController?.filterDataSource = freeTextFilterDataSource
            cell.configure(with: freeTextFilterViewController!.searchBar)

            return cell
        case .inline:
            let vertical = filterContainer.verticals?.first(where: { $0.isCurrent })
            let cell = tableView.dequeue(InlineFilterCell.self, for: indexPath)
            cell.delegate = self

            if let inlineFilter = filterContainer.inlineFilter {
                let segmentTitles = inlineFilter.subfilters.map({ $0.subfilters.map({ $0.title }) })
                let selectedItems = inlineFilter.subfilters.map({
                    $0.subfilters.enumerated().compactMap({ index, filter in
                        self.selectionStore.isSelected(filter) ? index : nil
                    })
                })

                cell.configure(withTitles: segmentTitles, verticalTitle: vertical?.title, selectedItems: selectedItems)
            }

            if shouldResetInlineFilterCell {
                shouldResetInlineFilterCell = false
                cell.resetContentOffset()
            }

            return cell
        case .rootFilters:
            let currentFilter = filterContainer.rootFilters[indexPath.row]
            let titles = selectionStore.titles(for: currentFilter)
            let isValid = selectionStore.isValid(currentFilter)
            let cell = tableView.dequeue(RootFilterCell.self, for: indexPath)

            cell.delegate = self
            cell.configure(withTitle: currentFilter.title, selectionTitles: titles, isValid: isValid, style: currentFilter.style)

            let mutuallyExclusiveFilters = filterContainer.rootFilters.filter({
                currentFilter.mutuallyExclusiveFilterKeys.contains($0.key)
            })

            cell.isEnabled = !mutuallyExclusiveFilters.reduce(false) {
                $0 || selectionStore.hasSelectedSubfilters(for: $1)
            }

            cell.isSeparatorHidden = indexPath.row == filterContainer.rootFilters.count - 1
            cell.accessibilityIdentifier = currentFilter.title

            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension RootFilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }

        switch section {
        case .rootFilters:
            delegate?.filterViewController(self, didSelectFilter: filterContainer.rootFilters[indexPath.row])
        case .freeText, .inline:
            return
        }
    }
}

// MARK: - RootFilterCellDelegate

extension RootFilterViewController: RootFilterCellDelegate {
    func rootFilterCell(_ cell: RootFilterCell, didRemoveTagAt index: Int) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        let currentFilter = filterContainer.rootFilters[indexPath.row]
        let selectedSubfilters = selectionStore.selectedSubfilters(for: currentFilter)
        let filterToRemove = selectedSubfilters[index]

        selectionStore.removeValues(for: filterToRemove)
        rootDelegate?.rootFilterViewController(self, didRemoveFilter: filterToRemove)
        reloadCellsWithExclusiveFilters(for: currentFilter)
    }

    func rootFilterCellDidRemoveAllTags(_ cell: RootFilterCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        let currentFilter = filterContainer.rootFilters[indexPath.row]

        selectionStore.removeValues(for: currentFilter)
        rootDelegate?.rootFilterViewController(self, didRemoveFilter: currentFilter)
        reloadCellsWithExclusiveFilters(for: currentFilter)
    }

    private func reloadCellsWithExclusiveFilters(for filter: Filter) {
        let keys = filter.mutuallyExclusiveFilterKeys

        let indexPathsToReload = filterContainer.rootFilters.enumerated().compactMap({ index, subfilter in
            return keys.contains(subfilter.key) ? IndexPath(row: index, section: Section.rootFilters.rawValue) : nil
        })

        tableView.reloadRows(at: indexPathsToReload, with: .none)
    }
}

// MARK: - CCInlineFilterViewDelegate

extension RootFilterViewController: InlineFilterViewDelegate {
    func inlineFilterView(_ inlineFilteView: InlineFilterView, didChange segment: Segment, at index: Int) {
        guard let inlineFilter = filterContainer.inlineFilter else { return }

        if let subfilter = inlineFilter.subfilter(at: index) {
            selectionStore.removeValues(for: subfilter)

            for index in segment.selectedItems {
                if let subfilter = subfilter.subfilter(at: index) {
                    selectionStore.setValue(from: subfilter)
                }
            }

            rootDelegate?.rootFilterViewController(self, didSelectInlineFilter: inlineFilter)
        }
    }

    func inlineFilterView(_ inlineFilterview: InlineFilterView, didTapExpandableSegment segment: Segment) {
        guard let verticals = filterContainer.verticals else { return }

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
        func dismissVerticalViewController(animated: Bool) {
            DispatchQueue.main.async {
                verticalViewController.dismiss(animated: animated)
            }
        }

        if let vertical = filterContainer.verticals?[safe: index], !vertical.isCurrent {
            freeTextFilterViewController?.searchBar.text = nil
            dismissVerticalViewController(animated: false)
            rootDelegate?.rootFilterViewController(self, didSelectVertical: vertical)
        } else {
            dismissVerticalViewController(animated: true)
        }
    }
}

// MARK: - FreeTextFilterViewControllerDelegate

extension RootFilterViewController: FreeTextFilterViewControllerDelegate {
    func freeTextFilterViewController(_ viewController: FreeTextFilterViewController, didSelect value: String?, for filter: Filter) {
        rootDelegate?.rootFilterViewController(self, didSelectFreeTextFilter: filter)
    }

    func freeTextFilterViewControllerWillBeginEditing(_ viewController: FreeTextFilterViewController) {
        resetButton.isEnabled = false
        add(viewController)
    }

    func freeTextFilterViewControllerWillEndEditing(_ viewController: FreeTextFilterViewController) {
        resetButton.isEnabled = true
        viewController.remove()
        tableView.reloadData()
    }
}
