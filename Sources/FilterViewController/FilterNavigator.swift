//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class FilterNavigator {
    public enum Destination {
        case subLevel(filterInfo: MultiLevelListSelectionFilterInfoType, delegate: FilterViewControllerDelegate?, parent: ApplySelectionButtonOwner)
        case root
    }

    typealias Factory = SublevelViewControllerFactory

    let navigationController: UINavigationController
    let factory: Factory
    let dataSource: FilterDataSource

    init(navigationController: UINavigationController, factory: Factory, dataSource: FilterDataSource) {
        self.navigationController = navigationController
        self.factory = factory
        self.dataSource = dataSource
    }

    public func start() {
    }

    public func navigate(to destination: FilterNavigator.Destination) {
        switch destination {
        case let .subLevel(filterInfo, delegate, parent):
            guard let sublevelViewController = factory.makeSublevelViewController(for: filterInfo, navigator: self, delegate: delegate) else {
                return
            }
            sublevelViewController.showsApplySelectionButton = parent.showsApplySelectionButton
            sublevelViewController.parentApplySelectionButtonOwner = parent
            navigationController.pushViewController(sublevelViewController, animated: true)
        case .root:
            navigationController.popToRootViewController(animated: true)
        }
    }
}
