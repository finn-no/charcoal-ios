//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol ViewControllerFactory {
    func makeFilterRootViewController(navigator: RootFilterNavigator) -> FilterRootViewController
    func makeListViewControllerForPreference(with preferenceInfo: PreferenceInfo) -> UIViewController?
    func makeViewControllerForFilterComponent(at index: Int, navigator: RootFilterNavigator) -> UIViewController?
    func makeListViewControllerForMultiLevelFilterComponent(from multiLevelFilterInfo: MultiLevelFilterInfo, navigator: RootFilterNavigator) -> ListViewController?
}
