//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

extension Int {
    init?(_ string: String?) {
        guard let string = string else { return nil }
        self.init(string)
    }

    var decimalFormatted: String {
        return NumberFormatter.decimalFormatter.string(from: self) ?? ""
    }
}
