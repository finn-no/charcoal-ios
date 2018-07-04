//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class MultiLevelListSelectionFilterViewController: ListViewController, FilterContainerViewController {
    let filterInfo: MultiLevelListSelectionFilterInfoType

    public var filterSelectionDelegate: FilterContainerViewControllerDelegate?

    public var controller: UIViewController {
        return self
    }

    public init?(filterInfo: FilterInfoType) {
        guard let multiLevelFilterInfo = filterInfo as? MultiLevelListSelectionFilterInfoType else {
            return nil
        }

        self.filterInfo = multiLevelFilterInfo
        super.init(title: multiLevelFilterInfo.name, items: multiLevelFilterInfo.filters, allowsMultipleSelection: multiLevelFilterInfo.isMultiSelect)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sublevelFilterInfo = filterInfo.filters[indexPath.row]
        var selectionValue: FilterSelectionValue?

        if filterInfo.isMultiSelect {
            if let values = tableView.indexPathsForSelectedRows?.compactMap({ filterInfo.filters[$0.row].value }) {
                selectionValue = .multipleSelection(values: values)
            }
        } else {
            if let value = tableView.indexPathForSelectedRow.flatMap({ filterInfo.filters[$0.row].value }) {
                selectionValue = .singleSelection(value: value)
            }
        }

        if let selectionValue = selectionValue {
            filterSelectionDelegate?.filterContainerViewController(filterContainerViewController: self, didUpdateFilterSelectionValue: selectionValue)
        }

        if sublevelFilterInfo.filters.isEmpty == false {
            filterSelectionDelegate?.filterContainerViewController(filterContainerViewController: self, navigateTo: sublevelFilterInfo)
        }
    }

    public func setSelectionValue(_ selectionValue: FilterSelectionValue) {
    }
}
