//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol ViewControllerFactory: MultiLevelFilterListViewControllerFactory {
    func makeFilterRootViewController(navigator: RootFilterNavigator) -> FilterRootViewController
    func makePreferenceFilterListViewController(with preferenceInfo: PreferenceInfoType, delegate: PreferenceFilterListViewControllerDelegate) -> PreferenceFilterListViewController?
}

public protocol MultiLevelFilterListViewControllerFactory {
    func makeMultiLevelFilterListViewController(from multiLevelFilterInfo: MultiLevelFilterInfoType, navigator: MultiLevelFilterNavigator) -> MultiLevelFilterListViewController
}
