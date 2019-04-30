//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

/// Class for referencing the framework bundle
public class FINNSetup {
    static var bundle: Bundle {
        return Bundle(for: FINNSetup.self)
    }
}

public extension Bundle {
    static var finnSetup: Bundle {
        return FINNSetup.bundle
    }
}
