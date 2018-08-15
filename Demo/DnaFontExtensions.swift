//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit
import UIKit

extension UIFont {
    var isDynamicTypeEnabled: Bool {
        return FilterKit.isDynamicTypeEnabled
    }

    static var bundle: Bundle {
        return .filterKit
    }
}
