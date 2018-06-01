//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class FilterDependencyContainer {
    private let dataSource: FilterDataSource

    public init(dataSource: FilterDataSource) {
        self.dataSource = dataSource
    }
}

extension FilterDependencyContainer: NavigatorFactory {
    public func makeMultiLevelFilterNavigator(navigationController: UINavigationController) -> MultiLevelFilterNavigator {
        return MultiLevelFilterNavigator(navigationController: navigationController, factory: self)
    }

    public func makeRootFilterNavigator(navigationController: FilterNavigationController) -> RootFilterNavigator {
        return RootFilterNavigator(navigationController: navigationController, factory: self)
    }
}

extension FilterDependencyContainer: ViewControllerFactory {
    public func makePreferenceFilterListViewController(with preferenceInfo: PreferenceInfoType, delegate: PreferenceFilterListViewControllerDelegate) -> PreferenceFilterListViewController? {
        let preferenceFilterListViewController = PreferenceFilterListViewController(preferenceInfo: preferenceInfo)
        preferenceFilterListViewController.delegate = delegate

        return preferenceFilterListViewController
    }

    public func makeMultiLevelFilterListViewController(from multiLevelFilterInfo: MultiLevelFilterInfoType, navigator: MultiLevelFilterNavigator) -> MultiLevelFilterListViewController {
        return MultiLevelFilterListViewController(filterInfo: multiLevelFilterInfo, navigator: navigator)
    }

    public func makeFilterRootViewController(navigator: RootFilterNavigator) -> FilterRootViewController {
        return FilterRootViewController(title: dataSource.filterTitle, navigator: navigator, dataSource: dataSource)
    }
}
