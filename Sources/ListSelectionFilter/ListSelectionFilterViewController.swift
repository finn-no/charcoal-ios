//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class ListSelectionFilterViewController: ListViewController, FilterContainerViewController {
    private let filterInfo: ListSelectionFilterInfoType
    public var filterSelectionDelegate: FilterContainerViewControllerDelegate?
    private let selectionDataSource: FilterSelectionDataSource

    public var controller: UIViewController {
        return self
    }

    public init?(filterInfo: FilterInfoType, selectionDataSource: FilterSelectionDataSource) {
        guard let listSelectionFilterInfo = filterInfo as? ListSelectionFilterInfoType else {
            return nil
        }

        self.filterInfo = listSelectionFilterInfo
        self.selectionDataSource = selectionDataSource
        super.init(title: listSelectionFilterInfo.title, items: listSelectionFilterInfo.values)
        listViewControllerDelegate = self
        selectionListItemCellConfigurator = self
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func toggleSelection(for listItem: ListItem) {
        guard let item = listItem as? FilterValueType else {
            return
        }
        let wasItemPreviouslySelected = isListItemSelected(item)
        if filterInfo.isMultiSelect {
            if wasItemPreviouslySelected {
                selectionDataSource.clearValue(item.value, for: filterInfo)
            } else {
                selectionDataSource.addValue(item.value, for: filterInfo)
            }
        } else {
            selectionDataSource.clearAll(for: filterInfo)
            if !wasItemPreviouslySelected {
                selectionDataSource.setValue([item.value], for: filterInfo)
            }
        }
        filterSelectionDelegate?.filterContainerViewControllerDidChangeSelection(filterContainerViewController: self)
    }

    private func isListItemSelected(_ listItem: ListItem) -> Bool {
        guard let item = listItem as? FilterValueType else {
            return false
        }
        return isListSelectionFilterValueSelected(item)
    }

    private func isListSelectionFilterValueSelected(_ item: FilterValueType) -> Bool {
        guard let currentSelection = selectionDataSource.value(for: filterInfo) else {
            return false
        }
        return currentSelection.contains(item.value)
    }
}

extension ListSelectionFilterViewController: ListViewControllerDelegate {
    func listViewController(_: ListViewController, didSelectListItem listItem: ListItem, at indexPath: IndexPath, in tableView: UITableView) {
        toggleSelection(for: listItem)
        updateCellIfVisible(at: indexPath)
    }
}

extension ListSelectionFilterViewController: SelectionListItemCellConfigurator {
    func configure(_ cell: SelectionListItemCell, listItem: ListItem) {
        cell.configure(for: listItem)
        cell.selectionIndicatorType = filterInfo.isMultiSelect ? .checkbox : .radioButton
        cell.setSelectionMarker(visible: isListItemSelected(listItem))
    }
}
