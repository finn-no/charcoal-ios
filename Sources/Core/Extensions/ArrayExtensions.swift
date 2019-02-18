//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

extension Array {
    /// Returns nil if index < count
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : .none
    }
}
