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
        super.init(title: preferenceInfo.preferenceName, items: preferenceInfo.values, allowsMultipleSelection: preferenceInfo.isMultiSelect)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectionValue: FilterSelectionValue?

        if preferenceInfo.isMultiSelect {
            if let values = tableView.indexPathsForSelectedRows?.map({ preferenceInfo.values[$0.row].value }) {
                selectionValue = .multipleSelection(values: values)
            }
        } else {
            if let value = tableView.indexPathForSelectedRow.map({ preferenceInfo.values[$0.row].value }) {
                selectionValue = .singleSelection(value: value)
            }
        }

        selectionDataSource.setValue(selectionValue, for: preferenceInfo)
    }
}
