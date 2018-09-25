//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class ListSelectionFilterViewController: ListViewController, FilterContainerViewController {
    private let filterInfo: ListSelectionFilterInfoType
    private let listSelectionStateProvider: ListSelectionStateProvider
    public var filterSelectionDelegate: FilterContainerViewControllerDelegate?

    public var controller: UIViewController {
        return self
    }

    public init?(filterInfo: FilterInfoType) {
        guard let listSelectionFilterInfo = filterInfo as? ListSelectionFilterInfoType else {
            return nil
        }

        self.filterInfo = listSelectionFilterInfo
        listSelectionStateProvider = ListSelectionStateProvider(filterInfo: listSelectionFilterInfo, currentSelection: nil)
        super.init(title: listSelectionFilterInfo.title, items: listSelectionFilterInfo.values, allowsMultipleSelection: listSelectionFilterInfo.isMultiSelect, listItemSelectionStateProvider: listSelectionStateProvider)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let listItem = listItems[safe: indexPath.row] else {
            return
        }
        if listItem.showsDisclosureIndicator {
            // TODO: this needs to be handled in where subfilters are accessible, perhaps a func to override? OR should we know about subfilters since we know about disclosure?
            /* guard let selectedFilterInfo = filterInfo.values[safe: indexPath.row] else {
             return
             }
             filterSelectionDelegate?.filterContainerViewController(filterContainerViewController: self, navigateTo: selectedFilterInfo) */
            return
        } else {
            var indexPathsToUpdate = [indexPath]
            let wasSelected = listSelectionStateProvider.isListItemSelected(listItem)
            var selectionValue: FilterSelectionValue?

            if wasSelected {
                if filterInfo.isMultiSelect {
                    let previousSelectionValues = listSelectionStateProvider.currentSelection?.valuesArrayIfSingeOrMultiSelectionData() ?? []
                    selectionValue = .multipleSelection(values: previousSelectionValues.filter({ $0 != listItem.value }))
                } else {
                    selectionValue = nil
                }
            } else {
                if filterInfo.isMultiSelect {
                    let previousSelectionValues = listSelectionStateProvider.currentSelection?.valuesArrayIfSingeOrMultiSelectionData() ?? []
                    selectionValue = .multipleSelection(values: previousSelectionValues + [listItem.value])
                } else {
                    if let previousSelectionValues = listSelectionStateProvider.currentSelection?.valuesArrayIfSingeOrMultiSelectionData() {
                        let matches = listItems.enumerated().filter({ (_, item) -> Bool in
                            return previousSelectionValues.contains(item.value)
                        })
                        let matchingIndexPaths = matches.map({ (index, _) -> IndexPath in
                            return IndexPath(row: index, section: 0)
                        })
                        indexPathsToUpdate.append(contentsOf: matchingIndexPaths)
                    }
                    selectionValue = .singleSelection(value: listItem.value)
                }
            }

            if let selectionValue = selectionValue {
                filterSelectionDelegate?.filterContainerViewController(filterContainerViewController: self, didUpdateFilterSelectionValue: selectionValue, for: filterInfo)
            }
            listSelectionStateProvider.currentSelection = selectionValue

            tableView.reloadRows(at: indexPathsToUpdate, with: .fade)
        }
    }

    public func setSelectionValue(_ selectionValue: FilterSelectionValue) {
        listSelectionStateProvider.currentSelection = selectionValue
    }
}

private extension FilterSelectionValue {
    func valuesArrayIfSingeOrMultiSelectionData() -> [String]? {
        if case let .singleSelection(value) = self {
            return [value]
        } else if case let .multipleSelection(values) = self {
            return values
        }
        return nil
    }
}

public class ListSelectionStateProvider: ListItemSelectionStateProvider {
    let filterInfo: ListSelectionFilterInfoType
    var currentSelection: FilterSelectionValue?

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
