//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

enum StepValueResult {
    case exact(stepValue: Int)
    case between(closest: Int, lower: Int, higher: Int)
    case tooLow(closest: Int)
    case tooHigh(closest: Int)

    var closestStep: Int {
        switch self {
        case let .exact(stepValue):
            return stepValue
        case let .between(closest, _, _):
            return closest
        case let .tooLow(closest):
            return closest
        case let .tooHigh(closest):
            return closest
        }
    }
}
