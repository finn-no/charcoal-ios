//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

enum Step: Equatable {
    case value(index: Int, rounded: Bool)
    case lowerBound
    case upperBound

    var index: Int? {
        switch self {
        case let .value(index, _):
            return index
        case .lowerBound, .upperBound:
            return nil
        }
    }
}

// MARK: - Comparable

extension Step: Comparable {
    static func < (lhs: Step, rhs: Step) -> Bool {
        switch (lhs, rhs) {
        case let (.value(lhsIndex, _), .value(rhsIndex, _)):
            return lhsIndex < rhsIndex
        case (.lowerBound, .lowerBound):
            return false
        case (.upperBound, .upperBound):
            return false
        case (.lowerBound, _):
            return true
        case (_, .lowerBound):
            return false
        case (.upperBound, _):
            return false
        case (_, .upperBound):
            return true
        default:
            return false
        }
    }
}
