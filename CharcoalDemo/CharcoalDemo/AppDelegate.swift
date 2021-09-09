import Charcoal
import FinniversKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 13.0, *) {
            FinniversKit.Config.userInterfaceStyleSupport = .dynamic

            let navigationBarAppearance = UINavigationBar.appearance()
            navigationBarAppearance.isTranslucent = false
            navigationBarAppearance.tintColor = .textAction

            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = Theme.mainBackground

            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.textPrimary,
                .font: UIFont.bodyStrong,
            ]

            navigationBarAppearance.standardAppearance = appearance
            navigationBarAppearance.scrollEdgeAppearance = appearance
            navigationBarAppearance.compactAppearance = appearance
        } else {
            UINavigationBar.appearance().barTintColor = Theme.mainBackground
            UINavigationBar.appearance().tintColor = .btnPrimary
            UINavigationBar.appearance().isTranslucent = false
            UINavigationBar.appearance().titleTextAttributes = [.font: UIFont.bodyStrong, .foregroundColor: UIColor.textPrimary]
            UIBarButtonItem.appearance().setTitleTextAttributes([.font: UIFont.body, .foregroundColor: UIColor.textPrimary], for: .normal)
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
