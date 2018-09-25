//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class FilterNavigator: Navigator {
    public enum Destination {
        case subLevel(filterInfo: MultiLevelListSelectionFilterInfoType, selectionValue: FilterSelectionValue?, delegate: FilterViewControllerDelegate?)
    }

    typealias Factory = SublevelViewControllerFactory

    let navigationController: UINavigationController
    let factory: Factory

    init(navigationController: UINavigationController, factory: Factory) {
        self.navigationController = navigationController
        self.factory = factory
    }

    public func start() {
    }

    public func navigate(to destination: FilterNavigator.Destination) {
        switch destination {
        case let .subLevel(filterInfo, selectionValue, delegate):
            guard let sublevelViewController = factory.makeSublevelViewController(for: filterInfo, navigator: self, delegate: delegate) else {
                return
            }
            if let selectionValue = selectionValue {
                sublevelViewController.setSelectionValue(selectionValue)
            }
            navigationController.pushViewController(sublevelViewController, animated: true)
        }
    }
}
