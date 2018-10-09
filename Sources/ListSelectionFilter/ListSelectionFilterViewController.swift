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
        let currentSelection = selectionDataSource.value(for: filterInfo)
        var currentSelectionValues = [String]()
        if let currentSelection = currentSelection {
            switch currentSelection {
            case let .singleSelection(value):
                currentSelectionValues = [value]
            case let .multipleSelection(values):
                currentSelectionValues = values
            case .rangeSelection:
                break
            }
        }

        let wasItemPreviouslySelected = currentSelectionValues.contains(item.value)
        if wasItemPreviouslySelected {
            currentSelectionValues = currentSelectionValues.filter({ $0 != item.value })
        } else {
            currentSelectionValues.append(item.value)
        }
        selectionDataSource.setValue(.multipleSelection(values: currentSelectionValues), for: filterInfo)
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
        switch currentSelection {
        case let .singleSelection(value):
            return value == item.value
        case let .multipleSelection(values):
            return values.contains(item.value)
        case .rangeSelection:
            return false
        }
    }
}
