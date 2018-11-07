//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

private class SelectAllItem: ListItem {
    let title = "all_items_title".localized()
    var detail: String?
    let showsDisclosureIndicator = false
    var value: String = ""
}

public final class MultiLevelListSelectionFilterViewController: ListViewController, FilterContainerViewController {
    private let filterInfo: MultiLevelListSelectionFilterInfoType
    private let selectionDataSource: FilterSelectionDataSource
    private var indexPathToRefreshOnViewWillAppear: IndexPath?
    public var filterSelectionDelegate: FilterContainerViewControllerDelegate?
    private let isSelectAllIncluded: Bool

    public var controller: UIViewController {
        return self
    }

    public init?(filterInfo: FilterInfoType, selectionDataSource: FilterSelectionDataSource) {
        guard let multiLevelFilterInfo = filterInfo as? MultiLevelListSelectionFilterInfoType else {
            return nil
        }

        self.filterInfo = multiLevelFilterInfo
        self.selectionDataSource = selectionDataSource
        var filters: [ListItem] = multiLevelFilterInfo.filters
        isSelectAllIncluded = !multiLevelFilterInfo.value.isEmpty
        if isSelectAllIncluded {
            let selectAllItem = SelectAllItem()
            selectAllItem.value = multiLevelFilterInfo.value
            selectAllItem.detail = "\(multiLevelFilterInfo.results)"
            filters.insert(selectAllItem, at: 0)
        }
        super.init(title: multiLevelFilterInfo.title, items: filters)
        listViewControllerDelegate = self
        selectionListItemCellConfigurator = nil
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPathToRefreshOnViewWillAppear = indexPathToRefreshOnViewWillAppear {
            updateCellIfVisible(at: indexPathToRefreshOnViewWillAppear)
        }
        indexPathToRefreshOnViewWillAppear = nil
        if isSelectAllIncluded {
            updateCellIfVisible(at: IndexPath(row: 0, section: 0))
        }
    }

    override func updateCellIfVisible(at indexPath: IndexPath) {
        guard tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false else {
            return
        }
        if let cell = tableView.cellForRow(at: indexPath) as? MultiLevelSelectionListItemCell, let listItem = listItems[safe: indexPath.row] {
            configure(cell, listItem: listItem)
        }
    }

    func updateAllVisibleCells() {
        for cell in tableView.visibleCells {
            if let indexPath = tableView.indexPath(for: cell), let listItem = listItems[safe: indexPath.row], let cell = cell as? MultiLevelSelectionListItemCell {
                configure(cell, listItem: listItem)
            }
        }
    }

    override func registerCells(for tableView: UITableView) {
        tableView.register(MultiLevelSelectionListItemCell.self)
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(MultiLevelSelectionListItemCell.self, for: indexPath)
        if let listItem = listItems[safe: indexPath.row] {
            configure(cell, listItem: listItem)
        }
        return cell
    }

    private func didSelectDrillDownItem(_ listItem: ListItem, at indexPath: IndexPath) {
        let filterIndex = isSelectAllIncluded ? indexPath.row - 1 : indexPath.row
        guard let sublevelFilterInfo = filterInfo.filters[safe: filterIndex] else {
            return
        }
        filterSelectionDelegate?.filterContainerViewController(filterContainerViewController: self, navigateTo: sublevelFilterInfo)
        indexPathToRefreshOnViewWillAppear = indexPath
    }

    private func toggleSelectAllSelection(for listItem: ListItem) {
        let wasItemPreviouslySelected = isListItemSelected(listItem)
        if listItem is SelectAllItem {
            if wasItemPreviouslySelected {
                selectionDataSource.clearValue(filterInfo.value, for: filterInfo)
            } else {
                selectionDataSource.clearValueAndValueForChildren(for: filterInfo)
                selectionDataSource.addValue(filterInfo.value, for: filterInfo)
            }
        }
    }

    private func toggleSelection(for listItem: ListItem) {
        if listItem is SelectAllItem {
            toggleSelectAllSelection(for: listItem)
            return
        }

        guard let item = listItem as? MultiLevelListSelectionFilterInfoType, filterInfo.filters.contains(where: { $0.title == item.title && $0.value == item.value }) else {
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

    private func isListItemSelected(_ listItem: ListItem) -> Bool {
        if listItem is SelectAllItem {
            return selectionDataSource.selectionState(filterInfo) == .selected
        }

        guard let item = listItem as? MultiLevelListSelectionFilterInfoType else {
            return false
        }
        return !isListSelectionFilterValueNotSelected(item)
    }

    private func isListSelectionFilterValueNotSelected(_ item: MultiLevelListSelectionFilterInfoType) -> Bool {
        let selectionState = selectionDataSource.selectionState(item)
        return selectionState == .none
    }
}

extension MultiLevelListSelectionFilterViewController: ListViewControllerDelegate {
    func listViewController(_: ListViewController, didSelectListItem listItem: ListItem, at indexPath: IndexPath, in tableView: UITableView) {
        if listItem.showsDisclosureIndicator {
            didSelectDrillDownItem(listItem, at: indexPath)
        } else if listItem is SelectAllItem {
            toggleSelectAllSelection(for: listItem)
            updateAllVisibleCells()
        } else {
            toggleSelection(for: listItem)
            if filterInfo.isMultiSelect {
                updateCellIfVisible(at: indexPath)
                if isSelectAllIncluded {
                    updateCellIfVisible(at: IndexPath(row: 0, section: 0))
                }
            } else {
                updateAllVisibleCells()
            }
        }
    }
}

extension MultiLevelListSelectionFilterViewController {
    func configure(_ cell: MultiLevelSelectionListItemCell, listItem: ListItem) {
        cell.configure(for: listItem)
        if let item = listItem as? MultiLevelListSelectionFilterInfoType {
            cell.setSelectionState(selectionDataSource.selectionState(item))
        } else if listItem is SelectAllItem {
            if selectionDataSource.selectionState(filterInfo) == .selected {
                cell.setSelectionState(.selected)
            } else {
                cell.setSelectionState(.none)
            }
        }
    }
}
