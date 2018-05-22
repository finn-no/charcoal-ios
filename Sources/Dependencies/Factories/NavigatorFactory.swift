//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol NavigatorFactory: MultiLevelFilterNavigatorFactory {
    func makeRootFilterNavigator(navigationController: FilterNavigationController) -> RootFilterNavigator
}

public protocol MultiLevelFilterNavigatorFactory {
    func makeMultiLevelFilterNavigator(navigationController: UINavigationController) -> MultiLevelFilterNavigator
}
