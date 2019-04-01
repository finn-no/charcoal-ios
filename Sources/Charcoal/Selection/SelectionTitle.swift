//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

struct SelectionTitle: Equatable {
    let value: String
    let accessibilityLabel: String

    // MARK: - Init

    init(value: String) {
        self.init(value: value, accessibilityLabel: value)
    }

    init(value: String, accessibilityLabel: String) {
        self.value = value
        self.accessibilityLabel = accessibilityLabel
    }
}
