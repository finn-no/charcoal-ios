//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol ViewControllerFactory: SublevelViewControllerFactory {
    func makeFilterRootStateController(navigator: RootFilterNavigator) -> FilterRootStateController
    func makeVerticalListViewController(with verticals: [Vertical], delegate: VerticalListViewControllerDelegate) -> VerticalListViewController?
    func makeRangeFilterViewController(with filterInfo: RangeFilterInfoType, navigator: FilterNavigator) -> RangeFilterViewController
    func makeListSelectionFilterViewController(from listSelectionListFilterInfo: ListSelectionFilterInfoType, navigator: FilterNavigator) -> ListSelectionFilterViewController
    func makeMultiLevelListSelectionFilterViewController(from multiLevelListSelectionListFilterInfo: MultiLevelListSelectionFilterInfoType, navigator: FilterNavigator) -> MultiLevelListSelectionFilterViewController
    func makeStepperFilterViewController(with filterInfo: StepperFilterInfoType, navigator: FilterNavigator) -> StepperFilterViewController
}

public protocol SublevelViewControllerFactory {
    func makeSublevelViewController(for filterInfo: MultiLevelListSelectionFilterInfoType, navigator: FilterNavigator) -> MultiLevelListSelectionFilterViewController
    func makeMapFilterViewController(from multiLevelListSelectionListFilterInfo: MultiLevelListSelectionFilterInfoType, navigator: FilterNavigator) -> MapFilterViewController
}
