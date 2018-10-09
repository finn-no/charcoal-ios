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
        guard let item = listItem as? MultiLevelListSelectionFilterInfoType else {
            return
        }
        if filterInfo.filters.contains(where: { $0.title == item.title && $0.value == item.value }) {
            let currentSelection = selectionDataSource.value(for: item)
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
            selectionDataSource.setValue(.multipleSelection(values: currentSelectionValues), for: item)
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
