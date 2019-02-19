//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public struct StepSliderInfo {
    public let minimumValue: Int
    public let maximumValue: Int
    public let hasLowerBoundOffset: Bool
    public let hasUpperBoundOffset: Bool
    public let values: [Int]

    public var referenceValues: [Int] {
        var result = [Int]()

        if let first = values.first {
            result.append(first)
        }

        let centerIndex = Int(values.count / 2)

        if centerIndex > 0, centerIndex < values.count - 1 {
            result.append(values[centerIndex])
        }

        if let last = values.last {
            result.append(last)
        }

        return result
    }

    // MARK: - Init

    public init(minimumValue: Int,
                maximumValue: Int,
                stepValues: [Int],
                hasLowerBoundOffset: Bool,
                hasUpperBoundOffset: Bool,
                accessibilityStepIncrement: Int? = nil) {
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.hasLowerBoundOffset = hasLowerBoundOffset
        self.hasUpperBoundOffset = hasUpperBoundOffset
        values = ([minimumValue] + stepValues + [maximumValue]).compactMap({ $0 })
    }

    public init(minimumValue: Int,
                maximumValue: Int,
                incrementedBy increment: Int,
                hasLowerBoundOffset: Bool,
                hasUpperBoundOffset: Bool,
                accessibilityStepIncrement: Int? = nil) {
        var values = [Int]()
        var value = minimumValue

        while value + increment < maximumValue {
            value += increment
            values.append(value)
        }

        self.init(
            minimumValue: minimumValue,
            maximumValue: maximumValue,
            stepValues: values,
            hasLowerBoundOffset: hasLowerBoundOffset,
            hasUpperBoundOffset: hasUpperBoundOffset,
            accessibilityStepIncrement: accessibilityStepIncrement
        )
    }

    // MARK: - Helpers

    func value(for step: Step) -> Int? {
        if !hasLowerBoundOffset && step == .lowerBound {
            return minimumValue
        }

        if !hasUpperBoundOffset && step == .upperBound {
            return maximumValue
        }

        return values.value(for: step)
    }
}

public enum RangeValue {
    case minimum(lowValue: Int)
    case maximum(highValue: Int)
    case closed(lowValue: Int, highValue: Int)

    static func create(lowValue: Int?, highValue: Int?) -> RangeValue? {
        if let lowValue = lowValue {
            if let highValue = highValue {
                return .closed(lowValue: lowValue, highValue: highValue)
            } else {
                return .minimum(lowValue: lowValue)
            }
        } else if let highValue = highValue {
            return .maximum(highValue: highValue)
        }
        return nil
    }

    var lowValue: Int? {
        switch self {
        case let .minimum(lowValue):
            return lowValue
        case .maximum:
            return nil
        case let .closed(lowValue, _):
            return lowValue
        }
    }

    var highValue: Int? {
        switch self {
        case .minimum:
            return nil
        case let .maximum(highValue):
            return highValue
        case let .closed(_, highValue):
            return highValue
        }
    }
}
