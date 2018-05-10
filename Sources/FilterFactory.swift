//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class FilterFactory {
    public typealias Filter = FilterRootViewControllerDataSource & FilterRootViewControllerPreferenceDataSource
    public typealias Delegate = FilterRootViewControllerDelegate

    private let filter: Filter
    private weak var delegate: Delegate?

    public init(filter: Filter, delegate: Delegate) {
        self.filter = filter
        self.delegate = delegate
    }
}

extension FilterFactory: ViewControllerFactory {
    public func makeViewControllerForFilter(at filterIndex: Int, navigator: FilterNavigator) -> UIViewController? {
        let filterInfo = filter.filter(at: filterIndex)

        let viewController: UIViewController?
        switch filterInfo {
        case let multiLevelInfo as MultiLevelFilterInfo:
            viewController = makeMultiLevelFilterListViewController(from: multiLevelInfo, navigator: navigator)
        default:
            return nil
        }

        return viewController
    }

    public func makeMultiLevelFilterListViewController(from multiLevelFilterInfo: MultiLevelFilterInfo, navigator: FilterNavigator) -> UIViewController? {
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

    public func makeListViewControllerForPreference(at index: Int) -> UIViewController? {
        guard let preferenceInfo = filter.preference(at: index) else {
            return nil
        }

        let listItems = (0 ..< preferenceInfo.numberOfValues).compactMap({ preferenceInfo.value(at: $0) })
        let listViewController = ListViewController(title: preferenceInfo.name, items: listItems)

        listViewController.didSelectListItemHandler = { _, _ in
            // update filter
        }

        return listViewController
    }

    public func makeFilterRootViewController(navigator: FilterNavigator) -> FilterRootViewController {
        return FilterRootViewController(navigator: navigator, dataSource: filter, delegate: delegate)
    }
}
