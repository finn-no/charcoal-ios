//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class MultiLevelListSelectionFilterViewController: ListViewController, FilterContainerViewController {
    private let filterInfo: MultiLevelListSelectionFilterInfoType
    private let selectionDataSource: FilterSelectionDataSource
    private var indexPathToRefreshOnViewWillAppear: IndexPath?
    public var filterSelectionDelegate: FilterContainerViewControllerDelegate?

    public var controller: UIViewController {
        return self
    }

    public init?(filterInfo: FilterInfoType, selectionDataSource: FilterSelectionDataSource) {
        guard let multiLevelFilterInfo = filterInfo as? MultiLevelListSelectionFilterInfoType else {
            return nil
        }

        self.filterInfo = multiLevelFilterInfo
        self.selectionDataSource = selectionDataSource
        super.init(title: multiLevelFilterInfo.title, items: multiLevelFilterInfo.filters)
        listViewControllerDelegate = self
        selectionListItemCellConfigurator = nil
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPathToRefreshOnViewWillAppear = indexPathToRefreshOnViewWillAppear {
            updateCell(at: indexPathToRefreshOnViewWillAppear)
        }
        indexPathToRefreshOnViewWillAppear = nil
    }

    override func updateCell(at indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? MultiLevelSelectionListItemCell, let listItem = listItems[safe: indexPath.row] {
            configure(cell, listItem: listItem)
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
        guard let sublevelFilterInfo = filterInfo.filters[safe: indexPath.row] else {
            return
        }
        filterSelectionDelegate?.filterContainerViewController(filterContainerViewController: self, navigateTo: sublevelFilterInfo)
        indexPathToRefreshOnViewWillAppear = indexPath
    }

    private func toggleSelection(for listItem: ListItem) {
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
            selectionDataSource.clearAll(for: item)
            if !wasItemPreviouslySelected {
                selectionDataSource.setValue([item.value], for: item)
            }
        }
        filterSelectionDelegate?.filterContainerViewControllerDidChangeSelection(filterContainerViewController: self)
    }

    private func isListItemSelected(_ listItem: ListItem) -> Bool {
        guard let item = listItem as? MultiLevelListSelectionFilterInfoType else {
            return false
        }
        return isListSelectionFilterValueSelected(item)
    }

    private func isListSelectionFilterValueSelected(_ item: MultiLevelListSelectionFilterInfoType) -> Bool {
        let selectionState = selectionDataSource.selectionState(item)
        return selectionState != .none
    }
}

extension MultiLevelListSelectionFilterViewController: ListViewControllerDelegate {
    func listViewController(_: ListViewController, didSelectListItem listItem: ListItem, at indexPath: IndexPath, in tableView: UITableView) {
        if listItem.showsDisclosureIndicator {
            didSelectDrillDownItem(listItem, at: indexPath)
        } else {
            toggleSelection(for: listItem)
            updateCell(at: indexPath)
        }
    }
}

extension MultiLevelListSelectionFilterViewController {
    func configure(_ cell: MultiLevelSelectionListItemCell, listItem: ListItem) {
        cell.configure(for: listItem)
        if let item = listItem as? MultiLevelListSelectionFilterInfoType {
            cell.setSelectionState(selectionDataSource.selectionState(item))
        }
    }
}
