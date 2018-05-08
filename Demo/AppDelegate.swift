//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import HockeySDK
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        BITHockeyManager.shared().configure(withIdentifier: "dcb11108644344b5ae22b778ed0fcf9d")
        BITHockeyManager.shared().start()

        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = DemoViewsTableViewController()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()

        return true
    }
}
