//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol PreferenceFilterListViewControllerDelegate: ListViewControllerDelegate {
    func preferenceFilterListViewController(_ preferenceFilterListViewController: PreferenceFilterListViewController, with preferenceInfo: PreferenceInfoType, didSelect preferenceValue: PreferenceValueType)
}

extension ListViewControllerDelegate where Self: PreferenceFilterListViewControllerDelegate {
    public func listViewController(_ listViewController: ListViewController, didSelectListItem listItem: ListItem, atIndex index: Int) {
    }
}

public class PreferenceFilterListViewController: ListViewController, FilterContainerViewController {
    public var controller: UIViewController {
        return self
    }

    public var filterSelectionDelegate: FilterContainerViewControllerDelegate?

    let preferenceInfo: PreferenceInfoType

    public required init?(filterInfo: FilterInfoType) {
        guard let preferenceInfo = filterInfo as? PreferenceInfoType else {
            return nil
        }

        self.preferenceInfo = preferenceInfo

        super.init(title: preferenceInfo.name, items: preferenceInfo.values, allowsMultipleSelection: preferenceInfo.isMultiSelect)
    }

    public func setSelectionValue(_ selectionValue: FilterSelectionValue) {
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let preferenceValue = preferenceInfo.values[indexPath.row]
        (delegate as? PreferenceFilterListViewControllerDelegate)?.preferenceFilterListViewController(self, with: preferenceInfo, didSelect: preferenceValue)
    }
}
