//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class FilterNavigator {
    public enum Destination {
        case subLevel(filterInfo: MultiLevelListSelectionFilterInfoType, parent: ApplySelectionButtonOwner?)
        case root
        case map(filterInfo: MultiLevelListSelectionFilterInfoType, parent: ApplySelectionButtonOwner?)
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
        case let .subLevel(filterInfo, parent):
            let sublevelViewController = factory.makeSublevelViewController(for: filterInfo, navigator: self)
            sublevelViewController.parentApplyButtonOwner = parent
            navigationController.pushViewController(sublevelViewController, animated: true)
        case .root:
            navigationController.popToRootViewController(animated: true)
        case let .map(filterInfo, parent):
            let mapFilterViewController = factory.makeMapFilterViewController(from: filterInfo, navigator: self)
            mapFilterViewController.parentApplyButtonOwner = parent
            navigationController.pushViewController(mapFilterViewController, animated: true)
        }
    }
}
