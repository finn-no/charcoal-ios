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
        listSelectionStateProvider = ListSelectionStateProvider(filterInfo: listSelectionFilterInfo, currentSelection: nil)
        super.init(title: listSelectionFilterInfo.title, items: listSelectionFilterInfo.values, allowsMultipleSelection: listSelectionFilterInfo.isMultiSelect, listItemSelectionStateProvider: listSelectionStateProvider)
        listViewControllerDelegate = self
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        if let selectionValue = selectionDataSource.value(for: filterInfo) {
            setSelectionValue(selectionValue)
        }
    }

    private func setSelectionValue(_ selectionValue: FilterSelectionValue) {
        listSelectionStateProvider.currentSelection = selectionValue
    }
}

extension ListSelectionFilterViewController: ListViewControllerDelegate {
    public func listViewController(_: ListViewController, didSelectDrillDownItem listItem: ListItem, at indexPath: IndexPath) {
    }

    public func listViewController(_: ListViewController, didUpdateFilterSelectionValue selectionValue: FilterSelectionValue?, whenSelectingAt indexPath: IndexPath) {
        selectionDataSource.setValue(selectionValue, for: filterInfo)
    }
}

private class ListSelectionStateProvider: ListItemSelectionStateProvider {
    private let filterInfo: ListSelectionFilterInfoType
    var currentSelection: FilterSelectionValue?
    var isMultiSelectList: Bool {
        return filterInfo.isMultiSelect
    }

    init(filterInfo: ListSelectionFilterInfoType, currentSelection: FilterSelectionValue? = nil) {
        self.filterInfo = filterInfo
        self.currentSelection = currentSelection
    }

    public func isListItemSelected(_ listItem: ListItem) -> Bool {
        guard let item = listItem as? ListSelectionFilterValueType else {
            return false
        }
        return isListSelectionFilterValueSelected(item)
    }

    private func isListSelectionFilterValueSelected(_ item: ListSelectionFilterValueType) -> Bool {
        guard let currentSelection = currentSelection else {
            return false
        }
        if filterInfo.values.contains(where: { $0.title == item.title && $0.value == item.value }) {
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
