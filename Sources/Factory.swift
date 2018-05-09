//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol Factory {
}

public protocol ViewControllerFactory: Factory {
    func makeFilterRootViewController(navigator: FilterNavigator) -> FilterRootViewController
    func makeListViewControllerForPreference(at index: Int) -> UIViewController?
}
