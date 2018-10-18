//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class PreferenceFilterListViewController: ListViewController, FilterContainerViewController {
    public var controller: UIViewController {
        return self
    }

    public var filterSelectionDelegate: FilterContainerViewControllerDelegate?

    let filterInfo: PreferenceInfoType
    private let selectionDataSource: FilterSelectionDataSource

    public required init?(filterInfo: FilterInfoType, selectionDataSource: FilterSelectionDataSource) {
        guard let filterInfo = filterInfo as? PreferenceInfoType else {
            return nil
        }

        self.filterInfo = filterInfo
        self.selectionDataSource = selectionDataSource
        super.init(title: filterInfo.preferenceName, items: filterInfo.values)
        listViewControllerDelegate = self
        selectionListItemCellConfigurator = self
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func toggleSelection(for listItem: ListItem) {
        guard let item = listItem as? PreferenceValueType else {
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
        guard let item = listItem as? PreferenceValueType else {
            return false
        }
        return isListSelectionFilterValueSelected(item)
    }

    private func isListSelectionFilterValueSelected(_ item: PreferenceValueType) -> Bool {
        guard let currentSelection = selectionDataSource.value(for: filterInfo) else {
            return false
        }
        return currentSelection.contains(item.value)
    }
}

extension PreferenceFilterListViewController: ListViewControllerDelegate {
    func listViewController(_: ListViewController, didSelectListItem listItem: ListItem, at indexPath: IndexPath, in tableView: UITableView) {
        toggleSelection(for: listItem)
        updateCell(at: indexPath)
    }
}

extension PreferenceFilterListViewController: SelectionListItemCellConfigurator {
    func configure(_ cell: SelectionListItemCell, listItem: ListItem) {
        cell.configure(for: listItem)
        cell.selectionIndicatorType = filterInfo.isMultiSelect ? .checkbox : .radioButton
        cell.setSelectionMarker(visible: isListItemSelected(listItem))
    }
}
