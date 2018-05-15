//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol NavigatorFactory {
    func makeRootFilterNavigator(navigationController: FilterNavigationController) -> RootFilterNavigator
}
