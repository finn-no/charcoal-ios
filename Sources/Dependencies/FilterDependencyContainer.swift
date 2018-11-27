//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class FilterDependencyContainer {
    private let dataSource: FilterDataSource
    private let selectionDataSource: FilterSelectionDataSource
    private let searchQuerySuggestionsDataSource: SearchQuerySuggestionsDataSource?
    private weak var filterRootStateControllerDelegate: FilterRootStateControllerDelegate?
    private let filterSelectionTitleProvider: FilterSelectionTitleProvider

    public init(dataSource: FilterDataSource, selectionDataSource: FilterSelectionDataSource, searchQuerySuggestionsDataSource: SearchQuerySuggestionsDataSource?, filterDelegate: FilterRootStateControllerDelegate?, filterSelectionTitleProvider: FilterSelectionTitleProvider) {
        self.dataSource = dataSource
        self.selectionDataSource = selectionDataSource
        self.searchQuerySuggestionsDataSource = searchQuerySuggestionsDataSource
        filterRootStateControllerDelegate = filterDelegate
        self.filterSelectionTitleProvider = filterSelectionTitleProvider
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
    public func makeFilterRootStateController(navigator: RootFilterNavigator) -> FilterRootStateController {
        let rootStateController = FilterRootStateController(navigator: navigator, selectionDataSource: selectionDataSource, filterSelectionTitleProvider: filterSelectionTitleProvider)
        rootStateController.delegate = filterRootStateControllerDelegate
        rootStateController.searchQuerySuggestionDataSource = searchQuerySuggestionsDataSource
        rootStateController.state = .filtersLoaded(filter: dataSource) // TODO: This should not happen here, will be refactored
        return rootStateController
    }

    public func makeListSelectionFilterViewController(from listSelectionListFilterInfo: ListSelectionFilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate?) -> FilterViewController<ListSelectionFilterViewController>? {
        let filterViewController = FilterViewController<ListSelectionFilterViewController>(filterInfo: listSelectionListFilterInfo, dataSource: dataSource, selectionDataSource: selectionDataSource, navigator: navigator)
        filterViewController?.delegate = delegate
        return filterViewController
    }

    public func makeMultiLevelListSelectionFilterViewController(from multiLevelListSelectionListFilterInfo: MultiLevelListSelectionFilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate?) -> FilterViewController<MultiLevelListSelectionFilterViewController>? {
        let filterViewController = FilterViewController<MultiLevelListSelectionFilterViewController>(filterInfo: multiLevelListSelectionListFilterInfo, dataSource: dataSource, selectionDataSource: selectionDataSource, navigator: navigator)
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
        let filterViewController = FilterViewController<RangeFilterViewController>(filterInfo: filterInfo, dataSource: dataSource, selectionDataSource: selectionDataSource, navigator: navigator)
        filterViewController?.delegate = delegate
        return filterViewController
    }

    public func makeVerticalListViewController(with verticals: [Vertical], delegate: VerticalListViewControllerDelegate) -> VerticalListViewController? {
        let verticalListViewController = VerticalListViewController(verticals: verticals)
        verticalListViewController.delegate = delegate
        return verticalListViewController
    }

    public func makeSearchQueryFilterViewController(from searchQueryFilterInfo: SearchQueryFilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate?) -> UIViewController? {
//        let filterViewController = FilterViewController<SearchQueryViewController>(filterInfo: searchQueryFilterInfo, dataSource: dataSource, selectionDataSource: selectionDataSource, navigator: navigator)
//        filterViewController?.delegate = delegate
//        (filterViewController?.filterContainerViewController as? SearchQueryViewController)?.searchQuerySuggestionsDataSource = searchQuerySuggestionsDataSource
//
//        return filterViewController
        return nil
    }

    public func makeStepperFilterViewController(with filterInfo: StepperFilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate) -> FilterViewController<StepperFilterViewController>? {
        let filterViewController = FilterViewController<StepperFilterViewController>(filterInfo: filterInfo, dataSource: dataSource, selectionDataSource: selectionDataSource, navigator: navigator)
        filterViewController?.delegate = delegate
        return filterViewController
    }
}
