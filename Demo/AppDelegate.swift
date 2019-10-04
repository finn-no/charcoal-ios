//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import AppCenterDistribute
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if !DEBUG
            MSAppCenter.start("dcb11108-6443-44b5-ae22-b778ed0fcf9d", withServices: [
                MSCrashes.self,
                MSDistribute.self,
            ])
            MSCrashes.setEnabled(true)
            MSDistribute.setEnabled(true)
            MSAppCenter.setLogLevel(.warning)
        #endif

        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = DemoTableViewController()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()

        UINavigationBar.appearance().barTintColor = .milk
        UINavigationBar.appearance().tintColor = .primaryBlue
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().titleTextAttributes = [.font: UIFont.bodyStrong, .foregroundColor: UIColor.licorice]
        UIBarButtonItem.appearance().setTitleTextAttributes([.font: UIFont.body], for: .normal)

        return true
    }
}
