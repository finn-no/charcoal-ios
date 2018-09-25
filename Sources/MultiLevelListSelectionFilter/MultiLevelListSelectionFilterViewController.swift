//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class MultiLevelListSelectionFilterViewController: ListViewController, FilterContainerViewController {
    private let filterInfo: MultiLevelListSelectionFilterInfoType
    private let listSelectionStateProvider: MultiLevelListSelectionStateProvider

    public var filterSelectionDelegate: FilterContainerViewControllerDelegate?

    public var controller: UIViewController {
        return self
    }

    public init?(filterInfo: FilterInfoType) {
        guard let multiLevelFilterInfo = filterInfo as? MultiLevelListSelectionFilterInfoType else {
            return nil
        }

        self.filterInfo = multiLevelFilterInfo
        listSelectionStateProvider = MultiLevelListSelectionStateProvider(filterInfo: multiLevelFilterInfo)
        super.init(title: multiLevelFilterInfo.title, items: multiLevelFilterInfo.filters, allowsMultipleSelection: multiLevelFilterInfo.isMultiSelect, listItemSelectionStateProvider: listSelectionStateProvider)
        listViewControllerDelegate = self
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setSelectionValue(_ selectionValue: FilterSelectionValue) {
        listSelectionStateProvider.currentSelection = selectionValue
    }
}

extension MultiLevelListSelectionFilterViewController: ListViewControllerDelegate {
    public func listViewController(_: ListViewController, didSelectDrillDownItem listItem: ListItem, at indexPath: IndexPath) {
        guard let sublevelFilterInfo = filterInfo.filters[safe: indexPath.row] else {
            return
        }
        filterSelectionDelegate?.filterContainerViewController(filterContainerViewController: self, navigateTo: sublevelFilterInfo)
    }

    public func listViewController(_: ListViewController, didUpdateFilterSelectionValue selectionValue: FilterSelectionValue?, whenSelectingAt indexPath: IndexPath) {
        guard let sublevelFilterInfo = filterInfo.filters[safe: indexPath.row] else {
            return
        }
        filterSelectionDelegate?.filterContainerViewController(filterContainerViewController: self, didUpdateFilterSelectionValue: selectionValue, for: sublevelFilterInfo)
    }
}

private class MultiLevelListSelectionStateProvider: ListItemSelectionStateProvider {
    private let filterInfo: MultiLevelListSelectionFilterInfoType
    var currentSelection: FilterSelectionValue?
    var isMultiSelectList: Bool {
        return filterInfo.isMultiSelect
    }

    init(filterInfo: MultiLevelListSelectionFilterInfoType, currentSelection: FilterSelectionValue? = nil) {
        self.filterInfo = filterInfo
        self.currentSelection = currentSelection
    }

    public func isListItemSelected(_ listItem: ListItem) -> Bool {
        guard let item = listItem as? MultiLevelListSelectionFilterInfoType else {
            return false
        }
        return isListSelectionFilterValueSelected(item)
    }

    private func isListSelectionFilterValueSelected(_ item: MultiLevelListSelectionFilterInfoType) -> Bool {
        guard let currentSelection = currentSelection else {
            return false
        }
        if filterInfo.filters.contains(where: { $0.title == item.title && $0.value == item.value }) {
            switch currentSelection {
            case let .singleSelection(value):
                return value == item.value
            case let .multipleSelection(values):
                return values.contains(item.value)
            case .rangeSelection:
                return false
            }
        }
        return false
    }
}
