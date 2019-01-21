//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

enum StepValueResult<T: SliderValueKind> {
    case exact(stepValue: T)
    case between(closest: T, lower: T, higher: T)
    case tooLow(closest: T)
    case tooHigh(closest: T)

    var closestStep: T {
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
