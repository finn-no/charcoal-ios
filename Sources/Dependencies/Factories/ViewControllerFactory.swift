//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol ViewControllerFactory: SublevelViewControllerFactory {
    func makeFilterRootStateController(navigator: RootFilterNavigator) -> FilterRootStateController
    func makeVerticalListViewController(with verticals: [Vertical], delegate: VerticalListViewControllerDelegate) -> VerticalListViewController?
    func makeRangeFilterViewController(with filterInfo: RangeFilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate) -> FilterViewController<RangeFilterViewController>?
    func makeListSelectionFilterViewController(from listSelectionListFilterInfo: ListSelectionFilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate?) -> FilterViewController<ListSelectionFilterViewController>?
    func makeMultiLevelListSelectionFilterViewController(from multiLevelListSelectionListFilterInfo: MultiLevelListSelectionFilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate?) -> FilterViewController<MultiLevelListSelectionFilterViewController>?
    func makeSearchQueryFilterViewController(from searchQueryFilterInfo: SearchQueryFilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate?) -> UIViewController?
    func makeStepperFilterViewController(with filterInfo: StepperFilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate) -> FilterViewController<StepperFilterViewController>?
}

public protocol SublevelViewControllerFactory {
    func makeSublevelViewController(for filterInfo: FilterInfoType, navigator: FilterNavigator, delegate: FilterViewControllerDelegate?) -> FilterViewController<MultiLevelListSelectionFilterViewController>?
}
