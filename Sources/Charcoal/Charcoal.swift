//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

/// Class for referencing the framework bundle
public class Charcoal {
    static var bundle: Bundle {
        return Bundle(for: Charcoal.self)
    }
}

public extension Bundle {
    static var charcoal: Bundle {
        return Charcoal.bundle
    }
}
