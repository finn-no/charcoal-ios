//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class ListSelectionFilterViewController: ListViewController, FilterContainerViewController {
    private let filterInfo: ListSelectionFilterInfoType
    private let listSelectionStateProvider: ListSelectionStateProvider
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
        listSelectionStateProvider = ListSelectionStateProvider(filterInfo: listSelectionFilterInfo, selectionDataSource: selectionDataSource)
        super.init(title: listSelectionFilterInfo.title, items: listSelectionFilterInfo.values, allowsMultipleSelection: listSelectionFilterInfo.isMultiSelect, listItemSelectionStateProvider: listSelectionStateProvider)
        listViewControllerDelegate = self
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ListSelectionFilterViewController: ListViewControllerDelegate {
    public func listViewController(_: ListViewController, didSelectDrillDownItem listItem: ListItem, at indexPath: IndexPath) {
    }
}

private class ListSelectionStateProvider: ListItemSelectionStateProvider {
    private let filterInfo: ListSelectionFilterInfoType
    let selectionDataSource: FilterSelectionDataSource
    var isMultiSelectList: Bool {
        return filterInfo.isMultiSelect
    }

    init(filterInfo: ListSelectionFilterInfoType, selectionDataSource: FilterSelectionDataSource) {
        self.filterInfo = filterInfo
        self.selectionDataSource = selectionDataSource
    }

    func toggleSelection(for listItem: ListItem) {
        guard let item = listItem as? ListSelectionFilterValueType else {
            return
        }
        let wasItemPreviouslySelected = isListItemSelected(item)
        if isMultiSelectList {
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
    }

    public func isListItemSelected(_ listItem: ListItem) -> Bool {
        guard let item = listItem as? ListSelectionFilterValueType else {
            return false
        }
        return isListSelectionFilterValueSelected(item)
    }

    private func isListSelectionFilterValueSelected(_ item: ListSelectionFilterValueType) -> Bool {
        guard let currentSelection = selectionDataSource.value(for: filterInfo) else {
            return false
        }
        return currentSelection.contains(item.value)
    }
}
