//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

/// Class for referencing the framework bundle
public class FilterKit {
    static var bundle: Bundle {
        return Bundle(for: FilterKit.self)
    }

    public static var isDynamicTypeEnabled: Bool = true
}

public extension Bundle {
    static var filterKit: Bundle {
        return FilterKit.bundle
    }
}

extension UIFont {
    var isDynamicTypeEnabled: Bool {
        return FilterKit.isDynamicTypeEnabled
    }

    static var bundle: Bundle {
        return .filterKit
    }
}
