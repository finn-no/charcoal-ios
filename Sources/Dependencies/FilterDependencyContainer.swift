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
    public func makeFilterNavigator(navigationController: UINavigationController) -> FilterNavigator {
        return FilterNavigator(navigationController: navigationController, factory: self)
    }

    public func makeRootFilterNavigator(navigationController: FilterNavigationController) -> RootFilterNavigator {
        return RootFilterNavigator(navigationController: navigationController, factory: self)
    }
}

extension FilterDependencyContainer: ViewControllerFactory {
    public func makeMultiLevelFilterListViewController(from multiLevelFilterInfo: MultiLevelSelectionFilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate?) -> UIViewController? {
        let shouldShowsApplySelectionButton = false // FIXME:
        let filterViewController = FilterViewController<MultiLevelFilterListViewController>(filterInfo: multiLevelFilterInfo, navigator: navigator, showsApplySelectionButton: shouldShowsApplySelectionButton)
        filterViewController?.delegate = delegate
        return filterViewController
    }

    public func makeSublevelViewController(for filterInfo: FilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate?) -> UIViewController? {
        guard let multiLevelFilterInfo = filterInfo as? MultiLevelSelectionFilterInfoType else {
            return nil
        }

        return makeMultiLevelFilterListViewController(from: multiLevelFilterInfo, navigator: navigator, delegate: delegate)
    }

    public func makeRangeFilterViewController(with filterInfo: RangeFilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate) -> UIViewController? {
        let filterViewController = FilterViewController<RangeFilterViewController>(filterInfo: filterInfo, navigator: navigator, showsApplySelectionButton: true)
        filterViewController?.delegate = delegate
        return filterViewController
    }

    public func makePreferenceFilterListViewController(with preferenceInfo: PreferenceInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate) -> UIViewController? {
        let filterViewController = FilterViewController<PreferenceFilterListViewController>(filterInfo: preferenceInfo, navigator: navigator, showsApplySelectionButton: false)
        filterViewController?.delegate = delegate
        return filterViewController
    }

    public func makeFilterRootViewController(navigator: RootFilterNavigator) -> FilterRootViewController {
        return FilterRootViewController(title: dataSource.filterTitle, navigator: navigator, dataSource: dataSource)
    }
}
