//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

extension String {
    func localized(withComment comment: String = "", bundle: Bundle = .charcoal) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: comment)
    }
}
