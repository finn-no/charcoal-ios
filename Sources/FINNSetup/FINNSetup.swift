//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

class FINNSetup {
    static var bundle: Bundle {
        return Bundle(for: FINNSetup.self)
    }
}

extension Bundle {
    static var finnSetup: Bundle {
        return FINNSetup.bundle
    }
}
