//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

/// Class for referencing the framework bundle
public class Charcoal {
    static var bundle: Bundle {
        #if SWIFT_PACKAGE
            return Bundle.module
        #else
            return Bundle(for: Charcoal.self)
        #endif
    }
}

public extension Bundle {
    static var charcoal: Bundle {
        return Charcoal.bundle
    }
}
