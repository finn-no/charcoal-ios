//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class ListSelectionFilterViewController: ListViewController, FilterContainerViewController {
    let filterInfo: ListSelectionFilterInfoType
    public var filterSelectionDelegate: FilterContainerViewControllerDelegate?

    public var controller: UIViewController {
        return self
    }

    public init?(filterInfo: FilterInfoType) {
        guard let listSelectionFilterInfo = filterInfo as? ListSelectionFilterInfoType else {
            return nil
        }

        self.filterInfo = listSelectionFilterInfo
        super.init(title: listSelectionFilterInfo.name, items: listSelectionFilterInfo.values, allowsMultipleSelection: listSelectionFilterInfo.isMultiSelect)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectionValue: FilterSelectionValue?

        if filterInfo.isMultiSelect {
            if let values = tableView.indexPathsForSelectedRows?.compactMap({ filterInfo.values[$0.row].value }) {
                selectionValue = .mulitpleSelection(values: values)
            }
        } else {
            if let value = tableView.indexPathForSelectedRow.flatMap({ filterInfo.values[$0.row].value }) {
                selectionValue = .singleSelection(value: value)
            }
        }

        if let selectionValue = selectionValue {
            filterSelectionDelegate?.filterContainerViewController(filterContainerViewController: self, didUpdateFilterSelectionValue: selectionValue)
        }
    }

    public func setSelectionValue(_ selectionValue: FilterSelectionValue) {
    }
}
