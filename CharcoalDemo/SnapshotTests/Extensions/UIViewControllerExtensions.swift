import UIKit

extension UIViewController {
    func setUserInterfaceStyle(_ userInterfaceStyle: SnapshotUserInterfaceStyle) {
        switch userInterfaceStyle {
        case .lightMode:
            overrideUserInterfaceStyle = .light
        case .darkMode:
            overrideUserInterfaceStyle = .dark
        }
    }
}
