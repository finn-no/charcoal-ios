//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class FilterFactory {
    public typealias DataSource = FilterRootViewControllerDataSource & FilterRootViewControllerPreferenceDataSource
    public typealias Delegate = FilterRootViewControllerDelegate

    private weak var dataSource: DataSource?
    private weak var delegate: Delegate?

    public init(dataSource: DataSource, delegate: Delegate) {
        self.dataSource = dataSource
        self.delegate = delegate
    }
}

extension FilterFactory: ViewControllerFactory {
    public func makeListViewControllerForPreference(at index: Int) -> UIViewController? {
        guard let preferenceInfo = dataSource?.preference(at: index) else {
            return nil
        }

        let valuesDataSource = PreferenceValuesSelectionDataSource(preferenceInfo: preferenceInfo)
        let listViewController = ValueSelectionViewController(valuesDataSource: valuesDataSource)

        return listViewController
    }

    public func makeFilterRootViewController(navigator: FilterNavigator) -> FilterRootViewController? {
        guard let dataSource = self.dataSource else {
            return nil
        }

        return FilterRootViewController(navigator: navigator, dataSource: dataSource, delegate: delegate)
    }
}
