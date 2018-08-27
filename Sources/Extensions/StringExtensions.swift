//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

extension String {
    func localized(withComment comment: String = "") -> String {
        return NSLocalizedString(self, tableName: nil, bundle: FilterKit.bundle, value: "", comment: comment)
    }
}
