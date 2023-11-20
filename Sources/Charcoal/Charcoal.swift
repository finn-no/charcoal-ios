//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class Charcoal {
    static let shared = Charcoal()

    static var configuration: CharcoalConfig!

    private init() {
        guard Charcoal.configuration != nil else {
            let description = String(describing: type(of: self))
            fatalError("You must call \(description).setup(_:) to set up Charcoal before use")
        }
    }

    /// Required setup to be able to use Charcoal
    public static func setup(_ configuration: CharcoalConfig) {
        self.configuration = configuration
    }

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
