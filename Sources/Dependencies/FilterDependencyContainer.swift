//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class FilterDependencyContainer {
    private let dataSource: FilterDataSource
    private let selectionDataSource: FilterSelectionDataSource
    private let searchQuerySuggestionsDataSource: SearchQuerySuggestionsDataSource?

    public init(dataSource: FilterDataSource, selectionDataSource: FilterSelectionDataSource, searchQuerySuggestionsDataSource: SearchQuerySuggestionsDataSource?) {
        self.dataSource = dataSource
        self.selectionDataSource = selectionDataSource
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
        let filterViewController = FilterViewController<ListSelectionFilterViewController>(filterInfo: listSelectionListFilterInfo, selectionDataSource: selectionDataSource, navigator: navigator)
        filterViewController?.delegate = delegate
        return filterViewController
    }

    public func makeMultiLevelListSelectionFilterViewController(from multiLevelListSelectionListFilterInfo: MultiLevelListSelectionFilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate?) -> FilterViewController<MultiLevelListSelectionFilterViewController>? {
        let filterViewController = FilterViewController<MultiLevelListSelectionFilterViewController>(filterInfo: multiLevelListSelectionListFilterInfo, selectionDataSource: selectionDataSource, navigator: navigator)
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
        let filterViewController = FilterViewController<RangeFilterViewController>(filterInfo: filterInfo, selectionDataSource: selectionDataSource, navigator: navigator)
        filterViewController?.delegate = delegate
        return filterViewController
    }

    public func makeVerticalListViewController(with verticals: [Vertical], navigator: FilterNavigator, delegate: FilterViewControllerDelegate) -> VerticalListViewController? {
        // let filterViewController = FilterViewController<PreferenceFilterListViewController>(filterInfo: preferenceInfo, selectionDataSource: selectionDataSource, navigator: navigator)
        // filterViewController?.delegate = delegate
        return nil
    }

    public func makeFilterRootViewController(navigator: RootFilterNavigator) -> FilterRootViewController {
        return FilterRootViewController(title: dataSource.filterTitle, navigator: navigator, dataSource: dataSource, selectionDataSource: selectionDataSource)
    }

    public func makeSearchQueryFilterViewController(from searchQueryFilterInfo: SearchQueryFilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate?) -> UIViewController? {
        let filterViewController = FilterViewController<SearchQueryViewController>(filterInfo: searchQueryFilterInfo, selectionDataSource: selectionDataSource, navigator: navigator)
        filterViewController?.delegate = delegate
        (filterViewController?.filterContainerViewController as? SearchQueryViewController)?.searchQuerySuggestionsDataSource = searchQuerySuggestionsDataSource

        return filterViewController
    }
}
