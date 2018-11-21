//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public typealias NavigatorFactory = RootFilterNavigatorFactory & FilterNavigtorFactory

public protocol RootFilterNavigatorFactory {
    func makeRootFilterNavigator(navigationController: FilterNavigationController) -> RootFilterNavigator
}

public protocol FilterNavigtorFactory {
    func makeFilterNavigator(navigationController: UINavigationController, dataSource: FilterDataSource) -> FilterNavigator
}
