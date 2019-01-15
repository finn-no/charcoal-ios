//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

extension MultiLevelListSelectionFilterViewController {
    private enum Section: Int, CaseIterable {
        case map = 0
        case all
        case values
    }
}

public final class MultiLevelListSelectionFilterViewController: FilterViewController {
    private let filterInfo: MultiLevelListSelectionFilterInfoType
    private let dataSource: FilterDataSource
    private let selectionDataSource: FilterSelectionDataSource

    private var indexPathToRefreshOnViewWillAppear: IndexPath?
    private let isSelectAllIncluded: Bool
    // Should be replaced with selectionDelegate
    private weak var parentFilter: MultiLevelListSelectionFilterViewController?

    private static var rowHeight: CGFloat = 48.0

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        registerCells(for: tableView)
        return tableView
    }()

    let listItems: [MultiLevelListSelectionFilterInfoType]

    public init(filterInfo: MultiLevelListSelectionFilterInfoType, dataSource: FilterDataSource, selectionDataSource: FilterSelectionDataSource) {
        self.filterInfo = filterInfo
        self.dataSource = dataSource
        self.selectionDataSource = selectionDataSource
        let filters = filterInfo.filters
        isSelectAllIncluded = !filterInfo.value.isEmpty && !filterInfo.isMapFilter
        listItems = filters
        super.init(nibName: nil, bundle: nil)
        title = filterInfo.title
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if selectionDataSource.selectionState(filterInfo) != .none {
            showApplyButton(true, animated: false)
        }
        if let indexPathToRefreshOnViewWillAppear = indexPathToRefreshOnViewWillAppear {
            updateCellIfVisible(at: indexPathToRefreshOnViewWillAppear)
        }
        indexPathToRefreshOnViewWillAppear = nil
        if isSelectAllIncluded {
            updateSelectAllCellIfVisible()
        }
    }

    private func setup() {
        view.insertSubview(tableView, belowSubview: applyButton)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: applyButton.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func updateSelectAllCellIfVisible() {
        guard isSelectAllIncluded else {
            return
        }
        let indexPath = IndexPath(row: 0, section: Section.all.rawValue)
        guard tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false else {
            return
        }
        if let cell = tableView.cellForRow(at: indexPath) as? MultiLevelSelectionListItemCell {
            configureSelectAll(for: cell)
        }
    }

    private func updateCellIfVisible(at indexPath: IndexPath) {
        guard indexPath.section == Section.values.rawValue, tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false else {
            return
        }
        if let cell = tableView.cellForRow(at: indexPath) as? MultiLevelSelectionListItemCell, let listItem = listItems[safe: indexPath.row] {
            configure(cell, listItem: listItem)
        }
    }

    private func updateAllVisibleCells() {
        for cell in tableView.visibleCells {
            if let indexPath = tableView.indexPath(for: cell), let cell = cell as? MultiLevelSelectionListItemCell {
                if indexPath.section == Section.all.rawValue {
                    configureSelectAll(for: cell)
                } else if let listItem = listItems[safe: indexPath.row] {
                    configure(cell, listItem: listItem)
                }
            }
        }
    }

    private func registerCells(for tableView: UITableView) {
        tableView.register(MultiLevelSelectionListItemCell.self)
        tableView.register(MapFilterCell.self)
    }

    private func didSelectDrillDownItem(_ listItem: MultiLevelListSelectionFilterInfoType, at indexPath: IndexPath) {
        let controller = MultiLevelListSelectionFilterViewController(filterInfo: listItem, dataSource: dataSource, selectionDataSource: selectionDataSource)
        controller.filterSelectionDelegate = filterSelectionDelegate
        controller.parentFilter = self
        navigationController?.pushViewController(controller, animated: true)
        indexPathToRefreshOnViewWillAppear = indexPath
    }

    private func toggleSelectAllSelection() {
        let wasItemPreviouslySelected = selectionDataSource.selectionState(filterInfo) == .selected
        if wasItemPreviouslySelected {
            selectionDataSource.clearValue(filterInfo.value, for: filterInfo)
        } else {
            selectionDataSource.clearValueAndValueForChildren(for: filterInfo)
            selectionDataSource.addValue(filterInfo.value, for: filterInfo)
        }
    }

    private func toggleSelection(for item: MultiLevelListSelectionFilterInfoType) {
        guard filterInfo.filters.contains(where: { $0.title == item.title && $0.value == item.value }) else {
            return
        }
        let wasItemPreviouslySelected = isListItemSelected(item)

        if filterInfo.isMultiSelect {
            if wasItemPreviouslySelected {
                selectionDataSource.clearValue(item.value, for: item)
            } else {
                selectionDataSource.addValue(item.value, for: item)
            }
        } else {
            selectionDataSource.clearValueAndValueForChildren(for: filterInfo)
            if !wasItemPreviouslySelected {
                selectionDataSource.setValue([item.value], for: item)
            }
        }
    }

    private func isListItemSelected(_ item: MultiLevelListSelectionFilterInfoType) -> Bool {
        return !isListSelectionFilterValueNotSelected(item)
    }

    private func isListSelectionFilterValueNotSelected(_ item: MultiLevelListSelectionFilterInfoType) -> Bool {
        let selectionState = selectionDataSource.selectionState(item)
        return selectionState == .none
    }

    private func configure(_ cell: MultiLevelSelectionListItemCell, listItem: MultiLevelListSelectionFilterInfoType) {
        cell.configure(title: listItem.title, hits: dataSource.numberOfHits(for: listItem), showDisclosureIndicator: listItem.showDisclosureIndicator, selectionState: selectionDataSource.selectionState(listItem))
    }

    private func configureSelectAll(for cell: MultiLevelSelectionListItemCell) {
        let selectionState: MultiLevelListItemSelectionState = selectionDataSource.selectionState(filterInfo) == .selected ? .selected : .none
        cell.configure(title: "all_items_title".localized(), hits: dataSource.numberOfHits(for: filterInfo), showDisclosureIndicator: false, selectionState: selectionState)
    }

    private func configureMapFilter(for cell: MapFilterCell) {
        cell.configure(title: "map_filter_title".localized(), showDisclosureIndicator: true, selected: false)
    }
}

extension MultiLevelListSelectionFilterViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            return 0
        }
        switch section {
        case .map:
            return filterInfo.isMapFilter ? 1 : 0
        case .all:
            return isSelectAllIncluded ? 1 : 0
        case .values:
            return listItems.count
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Not configured properly")
        }
        switch section {
        case .map:
            let cell = tableView.dequeue(MapFilterCell.self, for: indexPath)
            configureMapFilter(for: cell)
            return cell
        case .all:
            let cell = tableView.dequeue(MultiLevelSelectionListItemCell.self, for: indexPath)
            configureSelectAll(for: cell)
            return cell
        case .values:
            let cell = tableView.dequeue(MultiLevelSelectionListItemCell.self, for: indexPath)
            if let listItem = listItems[safe: indexPath.row] {
                configure(cell, listItem: listItem)
            }
            return cell
        }
    }
}

extension MultiLevelListSelectionFilterViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            return
        }
        switch section {
        case .map:
            let controller = MapFilterViewController(filterInfo: filterInfo, dataSource: dataSource, selectionDataSource: selectionDataSource)
            controller.filterSelectionDelegate = filterSelectionDelegate
            controller.mapFilterViewManager = filterSelectionDelegate?.filterViewControllerDidRequestMapManager(self)
            controller.searchLocationDataSource = filterSelectionDelegate?.filterViewControllerDidRequestSearchLocationDataSource(self)
            navigationController?.pushViewController(controller, animated: true)
        case .all:
            toggleSelectAllSelection()
            updateAllVisibleCells()
        case .values:
            if let listItem = listItems[safe: indexPath.row] {
                if listItem.showDisclosureIndicator {
                    didSelectDrillDownItem(listItem, at: indexPath)
                } else {
                    toggleSelection(for: listItem)
                    if filterInfo.isMultiSelect {
                        updateCellIfVisible(at: indexPath)
                        updateSelectAllCellIfVisible()
                    } else {
                        updateAllVisibleCells()
                    }
                }
            }
        }
        let showButton = selectionDataSource.selectionState(filterInfo) != .none
        showApplyButton(showButton, animated: true)
        parentFilter?.showApplyButton(showButton, animated: false)
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return type(of: self).rowHeight
    }
}

private extension MultiLevelListSelectionFilterInfoType {
    var showDisclosureIndicator: Bool {
        return filters.count > 0
    }
}
