//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

extension String {
    func localized(withComment comment: String = "") -> String {
        return NSLocalizedString(self, tableName: nil, bundle: FilterKit.bundle, value: "", comment: comment)
    }
}
