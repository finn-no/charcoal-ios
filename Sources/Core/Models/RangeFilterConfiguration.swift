//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public struct RangeFilterConfiguration: Equatable {
    public enum ValueKind {
        case incremented(Int)
        case steps([Int])
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

        let stepValues: [Int]

        switch valueKind {
        case let .incremented(increment):
            var values = [Int]()
            var value = minimumValue

            while value + increment < maximumValue {
                value += increment
                values.append(value)
            }

            stepValues = values
        case let .steps(values):
            stepValues = values
        }

        values = ([minimumValue] + stepValues + [maximumValue]).compactMap({ $0 })
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
