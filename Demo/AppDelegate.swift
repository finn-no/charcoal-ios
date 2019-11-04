//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import AppCenterDistribute
import Charcoal
import FinniversKit
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

        if #available(iOS 13.0, *) {
            FinniversKit.userInterfaceStyleSupport = .dynamic
        }

        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = DemoTableViewController()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()

        UINavigationBar.appearance().barTintColor = Theme.mainBackground
        UINavigationBar.appearance().tintColor = .btnPrimary
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().titleTextAttributes = [.font: UIFont.bodyStrong, .foregroundColor: UIColor.textPrimary]
        UIBarButtonItem.appearance().setTitleTextAttributes([.font: UIFont.body, .foregroundColor: UIColor.textPrimary], for: .normal)

        return true
    }
}
