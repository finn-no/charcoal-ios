//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class PreferenceFilterListViewController: ListViewController, FilterContainerViewController {
    public var controller: UIViewController {
        return self
    }

    public var filterSelectionDelegate: FilterContainerViewControllerDelegate?

    let preferenceInfo: PreferenceInfoType
    private let selectionDataSource: FilterSelectionDataSource

    public required init?(filterInfo: FilterInfoType, selectionDataSource: FilterSelectionDataSource) {
        guard let preferenceInfo = filterInfo as? PreferenceInfoType else {
            return nil
        }

        self.preferenceInfo = preferenceInfo
        self.selectionDataSource = selectionDataSource
        super.init(title: preferenceInfo.preferenceName, items: preferenceInfo.values, allowsMultipleSelection: preferenceInfo.isMultiSelect, listItemSelectionStateProvider: PreferenceSelectionStateProvider(filterInfo: preferenceInfo, selectionDataSource: selectionDataSource))
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class PreferenceSelectionStateProvider: ListItemSelectionStateProvider {
    private let filterInfo: PreferenceInfoType
    let selectionDataSource: FilterSelectionDataSource
    var isMultiSelectList: Bool {
        return filterInfo.isMultiSelect
    }

    init(filterInfo: PreferenceInfoType, selectionDataSource: FilterSelectionDataSource) {
        self.filterInfo = filterInfo
        self.selectionDataSource = selectionDataSource
    }

    func toggleSelection(for listItem: ListItem) {
        guard let item = listItem as? PreferenceValueType else {
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
