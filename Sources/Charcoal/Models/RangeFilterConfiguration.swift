//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

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
    public let unit: FilterUnit
    public let usesSmallNumberInputFont: Bool

    private let isIncremented: Bool

    public var referenceValues: [Int] {
        guard let first = values.first, let last = values.last else {
            return []
        }

        var result = Set<Int>()

        if isIncremented {
            result = [first, first + (last - first) / 2, last]
        } else {
            result = [first, last]

            let centerIndex = Int(values.count / 2)

            if centerIndex > 0, centerIndex < values.count - 1 {
                result.insert(values[centerIndex])
            }
        }

        return Array(result).sorted(by: <)
    }

    // MARK: - Init

    public init(minimumValue: Int,
                maximumValue: Int,
                valueKind: ValueKind,
                hasLowerBoundOffset: Bool,
                hasUpperBoundOffset: Bool,
                unit: FilterUnit,
                usesSmallNumberInputFont: Bool) {
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.hasLowerBoundOffset = hasLowerBoundOffset
        self.hasUpperBoundOffset = hasUpperBoundOffset
        self.unit = unit
        self.usesSmallNumberInputFont = usesSmallNumberInputFont

        switch valueKind {
        case let .incremented(increment):
            values = (minimumValue ... maximumValue).stepValues(with: [(from: minimumValue, increment: increment)])
            isIncremented = true
        case let .steps(values):
            self.values = ([minimumValue] + values + [maximumValue]).compactMap { $0 }
            isIncremented = false
        case let .intervals(array):
            values = (minimumValue ... maximumValue).stepValues(with: array)
            isIncremented = false
        }
    }

    // MARK: - Helpers

    func value(for step: Step) -> Int? {
        if !hasLowerBoundOffset, step == .lowerBound {
            return minimumValue
        }

        if !hasUpperBoundOffset, step == .upperBound {
            return maximumValue
        }

        return values.value(for: step)
    }
}

// MARK: - Private extensions

private extension ClosedRange where Bound == Int {
    func stepValues(with intervals: [RangeFilterConfiguration.StepInterval]) -> [Int] {
        let intervals = intervals.reversed()
        var index = lowerBound
        var values = [index]

        while index < upperBound {
            if let interval = intervals.first(where: { index >= $0.from }) {
                index += interval.increment
            } else {
                index += 1
            }

            if index > lowerBound, index < upperBound {
                values.append(index)
            }
        }

        values.append(upperBound)

        return values
    }
}
