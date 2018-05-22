//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol MultiLevelFilterListViewControllerDelegate: ListViewControllerDelegate {
    func multiLevelFilterListViewController(_ multiLevelFilterListViewController: MultiLevelFilterListViewController, with filterInfo: MultiLevelFilterInfo, didSelect sublevelFilterInfo: MultiLevelFilterInfo)
}

extension MultiLevelFilterListViewControllerDelegate {
    public func listViewController(_ listViewController: ListViewController, didSelectListItem listItem: ListItem, atIndex index: Int) {
    }
}

public final class MultiLevelFilterListViewController: ListViewController {
    let filterInfo: MultiLevelFilterInfo
    let navigator: MultiLevelFilterNavigator

    public init(filterInfo: MultiLevelFilterInfo, navigator: MultiLevelFilterNavigator) {
        self.filterInfo = filterInfo
        self.navigator = navigator
        super.init(title: filterInfo.name, items: filterInfo.filters, allowsMultipleSelection: filterInfo.isMultiSelect)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sublevelFilterInfo = filterInfo.filters[indexPath.row]
        let delegate = self.delegate as? MultiLevelFilterListViewControllerDelegate
        delegate?.multiLevelFilterListViewController(self, with: filterInfo, didSelect: sublevelFilterInfo)

        let shouldNavigateToSublevel = !sublevelFilterInfo.filters.isEmpty

        if shouldNavigateToSublevel {
            navigator.navigate(to: .subLevel(filterInfo: sublevelFilterInfo, delegate: delegate))
        }
    }
}
