//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public struct RangeFilterConfiguration: Equatable {
    public typealias StepInterval = (from: Int, increment: Int)

    public enum ValueKind {
        case incremented(Int)
        case steps([Int])
        case intervals(array: [StepInterval])
    }

    public let minimumValue: Int
    public let maximumValue: Int
    public let hasLowerBoundOffset: Bool
    public let hasUpperBoundOffset: Bool
    public let values: [Int]
    public let unit: String
    public let accessibilityValueSuffix: String?
    public let usesSmallNumberInputFont: Bool
    public let displaysUnitInNumberInput: Bool
    public let isCurrencyValueRange: Bool

    public var referenceValues: [Int] {
        var result = [Int]()

        if let first = values.first, let last = values.last {
            result.append(first)
            result.append(first + (last - first) / 2)
            result.append(last)
        }

        return result
    }

    // MARK: - Init

    public init(minimumValue: Int,
                maximumValue: Int,
                valueKind: ValueKind,
                hasLowerBoundOffset: Bool,
                hasUpperBoundOffset: Bool,
                unit: String,
                accessibilityValueSuffix: String?,
                usesSmallNumberInputFont: Bool,
                displaysUnitInNumberInput: Bool,
                isCurrencyValueRange: Bool) {
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.hasLowerBoundOffset = hasLowerBoundOffset
        self.hasUpperBoundOffset = hasUpperBoundOffset
        self.unit = unit
        self.accessibilityValueSuffix = accessibilityValueSuffix
        self.usesSmallNumberInputFont = usesSmallNumberInputFont
        self.displaysUnitInNumberInput = displaysUnitInNumberInput
        self.isCurrencyValueRange = isCurrencyValueRange

        switch valueKind {
        case let .incremented(increment):
            self.values = (minimumValue ... maximumValue).stepValues(with: [(from: minimumValue, increment: increment)])
        case let .steps(values):
            self.values = ([minimumValue] + values + [maximumValue]).compactMap({ $0 })
        case let .intervals(array):
            self.values = (minimumValue ... maximumValue).stepValues(with: array)
        }
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

// MARK: - Private extensions

private extension ClosedRange where Bound == Int {
    func stepValues(with intervals: [RangeFilterConfiguration.StepInterval]) -> [Int] {
        let intervals = intervals.reversed()
        var i = lowerBound
        var values = [i]

        while i < upperBound {
            if let interval = intervals.first(where: { i >= $0.from }) {
                i += interval.increment
            } else {
                i += 1
            }

            if i > lowerBound && i < upperBound {
                values.append(i)
            }
        }

        values.append(upperBound)

        return values
    }
}
