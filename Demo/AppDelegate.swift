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
        BITHockeyManager.shared().crashManager.crashManagerStatus = .autoSend
        BITHockeyManager.shared().logLevel = .warning
        BITHockeyManager.shared().isFeedbackManagerDisabled = true
        BITHockeyManager.shared().authenticator.identificationType = .anonymous
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()

        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = DemoViewsTableViewController()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()

        UINavigationBar.appearance().barTintColor = .milk
        UINavigationBar.appearance().tintColor = .primaryBlue
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().titleTextAttributes = [.font: UIFont.title4, .foregroundColor: UIColor.licorice]
        UIBarButtonItem.appearance().setTitleTextAttributes([.font: UIFont.body], for: .normal)

        return true
    }
}
