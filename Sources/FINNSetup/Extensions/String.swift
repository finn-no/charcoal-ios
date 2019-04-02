//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, bundle: Bundle.finnSetup, comment: "")
    }
}
