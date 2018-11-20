//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class MultiLevelListSelectionFilterViewController: UIViewController, FilterContainerViewController {
    private enum Section: Int, CaseIterable {
        case all = 0
        case values
    }

    private let filterInfo: MultiLevelListSelectionFilterInfoType
    private let dataSource: FilterDataSource
    private let selectionDataSource: FilterSelectionDataSource
    private var indexPathToRefreshOnViewWillAppear: IndexPath?
    public var filterSelectionDelegate: FilterContainerViewControllerDelegate?
    private let isSelectAllIncluded: Bool

    public var controller: UIViewController {
        return self
    }

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

    public init?(filterInfo: FilterInfoType, dataSource: FilterDataSource, selectionDataSource: FilterSelectionDataSource) {
        guard let multiLevelFilterInfo = filterInfo as? MultiLevelListSelectionFilterInfoType else {
            return nil
        }

        self.filterInfo = multiLevelFilterInfo
        self.dataSource = dataSource
        self.selectionDataSource = selectionDataSource
        let filters = multiLevelFilterInfo.filters
        isSelectAllIncluded = !multiLevelFilterInfo.value.isEmpty
        listItems = filters
        super.init(nibName: nil, bundle: nil)
        title = title
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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
    }

    private func didSelectDrillDownItem(_ listItem: MultiLevelListSelectionFilterInfoType, at indexPath: IndexPath) {
        filterSelectionDelegate?.filterContainerViewController(filterContainerViewController: self, navigateTo: listItem)
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
        filterSelectionDelegate?.filterContainerViewControllerDidChangeSelection(filterContainerViewController: self)
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
        filterSelectionDelegate?.filterContainerViewControllerDidChangeSelection(filterContainerViewController: self)
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
        case .all:
            return isSelectAllIncluded ? 1 : 0
        case .values:
            return listItems.count
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(MultiLevelSelectionListItemCell.self, for: indexPath)
        guard let section = Section(rawValue: indexPath.section) else {
            return cell
        }
        switch section {
        case .all:
            configureSelectAll(for: cell)
        case .values:
            if let listItem = listItems[safe: indexPath.row] {
                configure(cell, listItem: listItem)
            }
        }
        return cell
    }
}

extension MultiLevelListSelectionFilterViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            return
        }
        switch section {
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
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return type(of: self).rowHeight
    }
}

extension MultiLevelListSelectionFilterViewController: ScrollableContainerViewController {
    public var mainScrollableView: UIScrollView {
        return tableView
    }
}

private extension MultiLevelListSelectionFilterInfoType {
    var showDisclosureIndicator: Bool {
        return filters.count > 0
    }
}
