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
    public func makeListViewControllerForPreference(at index: Int) -> UIViewController? {
        guard let preferenceInfo = filter.preference(at: index) else {
            return nil
        }

        let listItems = (0 ..< preferenceInfo.numberOfValues).compactMap({ preferenceInfo.value(at: $0)?.name }).map(PreferenceListItem.init)
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
