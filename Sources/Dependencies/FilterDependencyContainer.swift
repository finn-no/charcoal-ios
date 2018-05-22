//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class FilterDependencyContainer {
    private let filterService: FilterService

    public init(filterService: FilterService) {
        self.filterService = filterService
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
    public func makeListViewControllerForPreference(with preferenceInfo: PreferenceInfo) -> UIViewController? {
        let listViewController = ListViewController(title: preferenceInfo.name, items: preferenceInfo.values)

        return listViewController
    }

    public func makeMultiLevelFilterListViewController(from multiLevelFilterInfo: MultiLevelFilterInfo, navigator: MultiLevelFilterNavigator) -> MultiLevelFilterListViewController {
        return MultiLevelFilterListViewController(filterInfo: multiLevelFilterInfo, navigator: navigator)
    }

    public func makeFilterRootViewController(navigator: RootFilterNavigator) -> FilterRootViewController {
        return FilterRootViewController(navigator: navigator, components: filterService.filterComponents)
    }
}
