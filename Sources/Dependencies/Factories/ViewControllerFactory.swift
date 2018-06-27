//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol ViewControllerFactory: MultiLevelListSelectionViewControllerFactory, SublevelViewControllerFactory {
    func makeFilterRootViewController(navigator: RootFilterNavigator) -> FilterRootViewController
    func makePreferenceFilterListViewController(with preferenceInfo: PreferenceInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate) -> UIViewController?
    func makeRangeFilterViewController(with filterInfo: RangeFilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate) -> UIViewController?
}

public protocol MultiLevelListSelectionViewControllerFactory {
    func makeMultiLevelListSelectionFilterViewController(from multiLevelSelectionListFilterInfo: MultiLevelListSelectionFilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate?) -> UIViewController?
}

public protocol SublevelViewControllerFactory {
    func makeSublevelViewController(for filterInfo: FilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate?) -> UIViewController?
}
