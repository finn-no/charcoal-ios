//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public typealias SliderValueKind = Comparable & Numeric

public struct StepSliderInfo<T: SliderValueKind> {
    public let minimumValue: T
    public let maximumValue: T
    public let range: ClosedRange<T>
    public let values: [T]
    public var lowerBound: Bound
    public var upperBound: Bound
    public let accessibilityStepIncrement: Int

    public var referenceValues: [T] {
        var result = [T]()

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

    public init(minimumValue: T,
                maximumValue: T,
                stepValues: [T],
                hasLowerBoundOffset: Bool,
                hasUpperBoundOffset: Bool,
                accessibilityStepIncrement: Int? = nil) {
        range = minimumValue ... maximumValue
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        values = ([minimumValue] + stepValues + [maximumValue]).compactMap({ $0 })

        lowerBound = Bound(
            stepValue: hasLowerBoundOffset ? minimumValue - 1 : minimumValue,
            hasOffset: hasLowerBoundOffset
        )

        upperBound = Bound(
            stepValue: hasUpperBoundOffset ? maximumValue + 1 : maximumValue,
            hasOffset: hasUpperBoundOffset
        )

        self.accessibilityStepIncrement = accessibilityStepIncrement ?? 1
    }

    public init(minimumValue: T,
                maximumValue: T,
                incrementedBy increment: T,
                hasLowerBoundOffset: Bool,
                hasUpperBoundOffset: Bool,
                accessibilityStepIncrement: Int? = nil) {
        var values = [T]()
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

    func isLowValueInValidRange(_ lowValue: T) -> Bool {
        if lowValue >= range.lowerBound {
            return !(lowValue == 0 && range.lowerBound == 0)
        } else {
            return false
        }
    }

    func isHighValueInValidRange(_ highValue: T) -> Bool {
        return highValue <= range.upperBound
    }
}

// MARK: - Helper types

extension StepSliderInfo {
    public struct Bound: Equatable {
        public let stepValue: T
        public let hasOffset: Bool
        public var offsetValue: T? {
            return hasOffset ? stepValue : nil
        }
    }
}
