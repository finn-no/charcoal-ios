//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class MultiLevelFilterNavigator: Navigator {
    public enum Destination {
        case subLevel(filterInfo: MultiLevelFilterInfo, delegate: MultiLevelFilterListViewControllerDelegate?)
    }

    typealias Factory = MultiLevelFilterNavigatorFactory & MultiLevelFilterListViewControllerFactory

    let navigationController: UINavigationController
    let factory: Factory

    init(navigationController: UINavigationController, factory: Factory) {
        self.navigationController = navigationController
        self.factory = factory
    }

    public func start() {
    }

    public func navigate(to destination: MultiLevelFilterNavigator.Destination) {
        switch destination {
        case let .subLevel(filterInfo, delegate):
            let navigator = factory.makeMultiLevelFilterNavigator(navigationController: navigationController)
            let viewController = factory.makeMultiLevelFilterListViewController(from: filterInfo, navigator: navigator)
            viewController.delegate = delegate

            navigationController.pushViewController(viewController, animated: true)
        }
    }
}
