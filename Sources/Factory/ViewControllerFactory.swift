//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol ViewControllerFactory {
    func makeFilterRootViewController(navigator: FilterNavigator) -> FilterRootViewController
    func makeListViewControllerForPreference(with preferenceInfo: PreferenceInfo) -> UIViewController?
    func makeViewControllerForFilterComponent(at index: Int, navigator: FilterNavigator) -> UIViewController?
    func makeListViewControllerForMultiLevelFilterComponent(from multiLevelFilterInfo: MultiLevelFilterInfo, navigator: FilterNavigator) -> ListViewController?
}
