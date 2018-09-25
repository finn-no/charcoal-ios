//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class FilterDependencyContainer {
    private let dataSource: FilterDataSource
    weak var delegate: FilterDelegate?
    private let searchQuerySuggestionsDataSource: SearchQuerySuggestionsDataSource?

    public init(dataSource: FilterDataSource, delegate: FilterDelegate, searchQuerySuggestionsDataSource: SearchQuerySuggestionsDataSource?) {
        self.dataSource = dataSource
        self.delegate = delegate
        self.searchQuerySuggestionsDataSource = searchQuerySuggestionsDataSource
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
    public func makeListSelectionFilterViewController(from listSelectionListFilterInfo: ListSelectionFilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate?) -> FilterViewController<ListSelectionFilterViewController>? {
        let filterViewController = FilterViewController<ListSelectionFilterViewController>(filterInfo: listSelectionListFilterInfo, navigator: navigator, showsApplySelectionButton: true)
        filterViewController?.delegate = delegate
        return filterViewController
    }

    public func makeMultiLevelListSelectionFilterViewController(from multiLevelListSelectionListFilterInfo: MultiLevelListSelectionFilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate?) -> FilterViewController<MultiLevelListSelectionFilterViewController>? {
        let filterViewController = FilterViewController<MultiLevelListSelectionFilterViewController>(filterInfo: multiLevelListSelectionListFilterInfo, navigator: navigator, showsApplySelectionButton: false)
        filterViewController?.delegate = delegate
        return filterViewController
    }

    public func makeSublevelViewController(for filterInfo: FilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate?) -> FilterViewController<MultiLevelListSelectionFilterViewController>? {
        guard let multiLevelFilterInfo = filterInfo as? MultiLevelListSelectionFilterInfoType else {
            return nil
        }

        return makeMultiLevelListSelectionFilterViewController(from: multiLevelFilterInfo, navigator: navigator, delegate: delegate)
    }

    public func makeRangeFilterViewController(with filterInfo: RangeFilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate) -> FilterViewController<RangeFilterViewController>? {
        let filterViewController = FilterViewController<RangeFilterViewController>(filterInfo: filterInfo, navigator: navigator, showsApplySelectionButton: true)
        filterViewController?.delegate = delegate
        return filterViewController
    }

    public func makePreferenceFilterListViewController(with preferenceInfo: PreferenceInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate) -> FilterViewController<PreferenceFilterListViewController>? {
        let filterViewController = FilterViewController<PreferenceFilterListViewController>(filterInfo: preferenceInfo, navigator: navigator, showsApplySelectionButton: false)
        filterViewController?.delegate = delegate
        return filterViewController
    }

    public func makeFilterRootViewController(navigator: RootFilterNavigator) -> FilterRootViewController {
        return FilterRootViewController(title: dataSource.filterTitle, navigator: navigator, dataSource: dataSource, delegate: delegate)
    }

    public func makeSearchQueryFilterViewController(from searchQueryFilterInfo: SearchQueryFilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate?) -> UIViewController? {
        let filterViewController = FilterViewController<SearchQueryViewController>(filterInfo: searchQueryFilterInfo, navigator: navigator, showsApplySelectionButton: false)
        filterViewController?.delegate = delegate
        (filterViewController?.filterContainerViewController as? SearchQueryViewController)?.searchQuerySuggestionsDataSource = searchQuerySuggestionsDataSource

        return filterViewController
    }
}
