//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol ViewControllerFactory: MultiLevelFilterListViewControllerFactory {
    func makeFilterRootViewController(navigator: RootFilterNavigator) -> FilterRootViewController
    func makePreferenceFilterListViewController(with preferenceInfo: PreferenceInfo, delegate: PreferenceFilterListViewControllerDelegate) -> PreferenceFilterListViewController?
}

public protocol MultiLevelFilterListViewControllerFactory {
    func makeMultiLevelFilterListViewController(from multiLevelFilterInfo: MultiLevelFilterInfo, navigator: MultiLevelFilterNavigator) -> MultiLevelFilterListViewController
}
