//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol ViewControllerFactory {
    func makeFilterRootViewController(navigator: RootFilterNavigator) -> FilterRootViewController
    func makePreferenceFilterListViewController(with preferenceInfo: PreferenceInfo, delegate: PreferenceFilterListViewControllerDelegate) -> PreferenceFilterListViewController?
    func makeListViewControllerForMultiLevelFilterComponent(from multiLevelFilterInfo: MultiLevelFilterInfo, navigator: RootFilterNavigator) -> ListViewController?
    func makeViewControllerForFilter(with filterInfo: FilterInfo, navigator: RootFilterNavigator) -> UIViewController?
}
