import Foundation
import UIKit

extension UIAlertController {
    static var locationSharingAlert: UIAlertController {
        let title = "map.locationError.title".localized()
        let message = "map.locationError.message".localized()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))

        let openSettingsAction = UIAlertAction(
            title: "map.locationError.settings".localized(),
            style: .default,
            handler: { _ in
                guard
                    let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                    UIApplication.shared.canOpenURL(settingsUrl)
                else { return }
                UIApplication.shared.open(settingsUrl)
            }
        )
        alert.addAction(openSettingsAction)
        alert.preferredAction = openSettingsAction

        return alert
    }
}
