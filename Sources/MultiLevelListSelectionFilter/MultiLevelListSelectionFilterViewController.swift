//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class MultiLevelListSelectionFilterViewController: FilterViewController {
    private enum Section: Int, CaseIterable {
        case map = 0
        case all
        case values
    }

    private let filterInfo: MultiLevelListSelectionFilterInfoType
    private var indexPathToRefreshOnViewWillAppear: IndexPath?
    private let isSelectAllIncluded: Bool

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

    public init(filterInfo: MultiLevelListSelectionFilterInfoType, dataSource: FilterDataSource, selectionDataSource: FilterSelectionDataSource, navigator: FilterNavigator) {
        self.filterInfo = filterInfo
        listItems = filterInfo.filters
        isSelectAllIncluded = !filterInfo.value.isEmpty && !filterInfo.isMapFilter
        super.init(dataSource: dataSource, selectionDataSource: selectionDataSource, navigator: navigator)
        title = filterInfo.title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        if let parentApplyButtonOwner = parentApplyButtonOwner, parentApplyButtonOwner.isShowingApplyButton {
            showApplyButton(true, animated: false)
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPathToRefreshOnViewWillAppear = indexPathToRefreshOnViewWillAppear {
            updateCellIfVisible(at: indexPathToRefreshOnViewWillAppear)
        }
        indexPathToRefreshOnViewWillAppear = nil
        if isSelectAllIncluded {
            updateSelectAllCellIfVisible()
        }
    }

    private func setup() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: applySelectionButton.topAnchor),
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
        navigator?.navigate(to: .subLevel(filterInfo: listItem, parent: self))
        indexPathToRefreshOnViewWillAppear = indexPath
    }

    private func toggleSelectAllSelection() {
        let wasItemPreviouslySelected = selectionDataSource.selectionState(filterInfo) == .selected
        if wasItemPreviouslySelected {
            selectionDataSource.clearValue(filterInfo.value, for: filterInfo)
        } else {
            selectionDataSource.setValueAndClearValueForChildren(filterInfo.value, for: filterInfo)
        }
        showApplyButton(true)
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
        showApplyButton(true)
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
            navigator?.navigate(to: .map(filterInfo: filterInfo, parent: self))
            break
        case .all:
            toggleSelectAllSelection()
            updateAllVisibleCells()
        case .values:
            guard let listItem = listItems[safe: indexPath.row] else {
                return
            }
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

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return type(of: self).rowHeight
    }
}

private extension MultiLevelListSelectionFilterInfoType {
    var showDisclosureIndicator: Bool {
        return filters.count > 0
    }
}
