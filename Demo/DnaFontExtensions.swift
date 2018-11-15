//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import UIKit

extension UIFont {
    var isDynamicTypeEnabled: Bool {
        return Charcoal.isDynamicTypeEnabled
    }

    static var bundle: Bundle {
        return .charcoal
    }
}
