//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

extension String {
    func localized(withComment comment: String = "", table: String? = nil, bundle: Bundle = .charcoal) -> String {
        return NSLocalizedString(self, tableName: table, bundle: bundle, value: "", comment: comment)
    }
}
