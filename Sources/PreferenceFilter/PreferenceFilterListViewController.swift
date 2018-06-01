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

public class PreferenceFilterListViewController: ListViewController {
    let preferenceInfo: PreferenceInfoType

    public init(preferenceInfo: PreferenceInfoType) {
        self.preferenceInfo = preferenceInfo
        super.init(title: preferenceInfo.name, items: preferenceInfo.values, allowsMultipleSelection: preferenceInfo.isMultiSelect)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let preferenceValue = preferenceInfo.values[indexPath.row]
        (delegate as? PreferenceFilterListViewControllerDelegate)?.preferenceFilterListViewController(self, with: preferenceInfo, didSelect: preferenceValue)
    }
}
