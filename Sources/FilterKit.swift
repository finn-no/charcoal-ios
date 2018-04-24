//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

/// Class for referencing the framework bundle
public class FilterKit {
    static var bundle: Bundle {
        return Bundle(for: FilterKit.self)
    }
}

public extension Bundle {
    static var filterKit: Bundle {
        return FilterKit.bundle
    }
}
