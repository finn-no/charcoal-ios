//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public struct SelectionTitle: Equatable {
    public let value: String
    public let accessibilityLabel: String

    // MARK: - Init

    public init(value: String) {
        self.init(value: value, accessibilityLabel: value)
    }

    public init(value: String, accessibilityLabel: String) {
        self.value = value
        self.accessibilityLabel = accessibilityLabel
    }
}
