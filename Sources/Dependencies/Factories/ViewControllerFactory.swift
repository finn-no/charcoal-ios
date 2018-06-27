//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol ViewControllerFactory: MultiLevelFilterListViewControllerFactory, SublevelViewControllerFactory {
    func makeFilterRootViewController(navigator: RootFilterNavigator) -> FilterRootViewController
    func makePreferenceFilterListViewController(with preferenceInfo: PreferenceInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate) -> UIViewController?
    func makeRangeFilterViewController(with filterInfo: RangeFilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate) -> UIViewController?
}

public protocol MultiLevelFilterListViewControllerFactory {
    func makeMultiLevelFilterListViewController(from multiLevelFilterInfo: MultiLevelFilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate?) -> UIViewController?
}

public protocol SublevelViewControllerFactory {
    func makeSublevelViewController(for filterInfo: FilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate?) -> UIViewController?
}
