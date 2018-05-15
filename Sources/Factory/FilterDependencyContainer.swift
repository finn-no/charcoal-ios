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


extension FilterDependencyContainer: ViewControllerFactory {
    public func makeListViewControllerForPreference(with preferenceInfo: PreferenceInfo) -> UIViewController? {
        let listViewController = ListViewController(title: preferenceInfo.name, items: preferenceInfo.values)

        listViewController.didSelectListItemHandler = { _, _ in
            // update filter
        }

        return listViewController
    }

    public func makeViewControllerForFilterComponent(at index: Int, navigator: FilterNavigator) -> UIViewController? {
        let component = filterService.filterComponents[index]
        let filterInfo = component.filterInfo

        let viewController: UIViewController?
        switch filterInfo {
        case let multiLevelInfo as MultiLevelFilterInfo:
            viewController = makeListViewControllerForMultiLevelFilterComponent(from: multiLevelInfo, navigator: navigator)
        default:
            return nil
        }

        return viewController
    }

    public func makeListViewControllerForMultiLevelFilterComponent(from multiLevelFilterInfo: MultiLevelFilterInfo, navigator: FilterNavigator) -> ListViewController? {
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

    public func makeFilterRootViewController(navigator: FilterNavigator) -> FilterRootViewController {
        return FilterRootViewController(navigator: navigator, components: filterService.filterComponents)
    }
}
