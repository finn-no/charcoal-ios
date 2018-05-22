//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol ViewControllerFactory: MultiLevelFilterListViewControllerFactory {
    func makeFilterRootViewController(navigator: RootFilterNavigator) -> FilterRootViewController
    func makeListViewControllerForPreference(with preferenceInfo: PreferenceInfo) -> UIViewController?
}

public protocol MultiLevelFilterListViewControllerFactory {
    func makeMultiLevelFilterListViewController(from multiLevelFilterInfo: MultiLevelFilterInfo, navigator: MultiLevelFilterNavigator) -> MultiLevelFilterListViewController
}
