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
    public func makeRootFilterNavigator(navigationController: FilterNavigationController) -> RootFilterNavigator {
        return RootFilterNavigator(navigationController: navigationController, factory: self)
    }
}

extension FilterDependencyContainer: ViewControllerFactory {
    public func makeViewControllerForFilter(with filterInfo: FilterInfo, navigator: RootFilterNavigator) -> UIViewController? {
        let viewController: UIViewController?

        switch filterInfo {
        case let multiLevelInfo as MultiLevelFilterInfo:
            viewController = makeListViewControllerForMultiLevelFilterComponent(from: multiLevelInfo, navigator: navigator)
        default:
            viewController = nil
        }

        return viewController
    }

    public func makeListViewControllerForPreference(with preferenceInfo: PreferenceInfo) -> UIViewController? {
        let listViewController = ListViewController(title: preferenceInfo.name, items: preferenceInfo.values)

        listViewController.didSelectListItemHandler = { _, _ in
            // update filter
        }

        return listViewController
    }

    public func makeListViewControllerForMultiLevelFilterComponent(from multiLevelFilterInfo: MultiLevelFilterInfo, navigator: RootFilterNavigator) -> ListViewController? {
        if multiLevelFilterInfo.filters.isEmpty {
            return nil
        }

        let listItems = multiLevelFilterInfo.filters
        let listViewController = ListViewController(title: multiLevelFilterInfo.name, items: listItems, allowsMultipleSelection: true)

        listViewController.didSelectListItemHandler = { _, index in
            guard let subLevelFilter = multiLevelFilterInfo.filters[safe: index] else {
                return
            }

            navigator.navigate(to: .mulitlevelFilter(mulitlevelFilterInfo: subLevelFilter))
        }

        return listViewController
    }

    public func makeFilterRootViewController(navigator: RootFilterNavigator) -> FilterRootViewController {
        return FilterRootViewController(navigator: navigator, components: filterService.filterComponents)
    }
}
