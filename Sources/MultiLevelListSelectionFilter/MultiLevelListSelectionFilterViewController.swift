//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class MultiLevelListSelectionFilterViewController: ListViewController, FilterContainerViewController {
    private let filterInfo: MultiLevelListSelectionFilterInfoType
    private let selectionDataSource: FilterSelectionDataSource
    private let listSelectionStateProvider: MultiLevelListSelectionStateProvider

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
        listSelectionStateProvider = MultiLevelListSelectionStateProvider(filterInfo: multiLevelFilterInfo, selectionDataSource: selectionDataSource)
        super.init(title: multiLevelFilterInfo.title, items: multiLevelFilterInfo.filters, allowsMultipleSelection: multiLevelFilterInfo.isMultiSelect, listItemSelectionStateProvider: listSelectionStateProvider)
        listViewControllerDelegate = self
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MultiLevelListSelectionFilterViewController: ListViewControllerDelegate {
    public func listViewController(_: ListViewController, didSelectDrillDownItem listItem: ListItem, at indexPath: IndexPath) {
        guard let sublevelFilterInfo = filterInfo.filters[safe: indexPath.row] else {
            return
        }
        filterSelectionDelegate?.filterContainerViewController(filterContainerViewController: self, navigateTo: sublevelFilterInfo)
    }
}

private class MultiLevelListSelectionStateProvider: ListItemSelectionStateProvider {
    private let filterInfo: MultiLevelListSelectionFilterInfoType
    let selectionDataSource: FilterSelectionDataSource
    var isMultiSelectList: Bool {
        return filterInfo.isMultiSelect
    }

    init(filterInfo: MultiLevelListSelectionFilterInfoType, selectionDataSource: FilterSelectionDataSource) {
        self.filterInfo = filterInfo
        self.selectionDataSource = selectionDataSource
    }

    func toggleSelection(for listItem: ListItem) {
        guard let item = listItem as? MultiLevelListSelectionFilterInfoType, filterInfo.filters.contains(where: { $0.title == item.title && $0.value == item.value }) else {
            return
        }
        let wasItemPreviouslySelected = isListItemSelected(item)
        if isMultiSelectList {
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
    }

    public func isListItemSelected(_ listItem: ListItem) -> Bool {
        guard let item = listItem as? MultiLevelListSelectionFilterInfoType else {
            return false
        }
        return isListSelectionFilterValueSelected(item)
    }

    private func isListSelectionFilterValueSelected(_ item: MultiLevelListSelectionFilterInfoType) -> Bool {
        guard let currentSelection = selectionDataSource.value(for: item) else {
            return false
        }
        if filterInfo.filters.contains(where: { $0.title == item.title && $0.value == item.value }) {
            return currentSelection.contains(item.value)
        }
        return false
    }
}
