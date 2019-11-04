//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import FinniversKit
import HockeySDK
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        BITHockeyManager.shared().configure(withIdentifier: "dcb11108644344b5ae22b778ed0fcf9d")
        BITHockeyManager.shared().crashManager.crashManagerStatus = .autoSend
        BITHockeyManager.shared().logLevel = .warning
        BITHockeyManager.shared().isFeedbackManagerDisabled = true
        BITHockeyManager.shared().authenticator.identificationType = .anonymous
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()

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
