//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public typealias SliderValueKind = Comparable & Numeric

public struct StepSliderInfo<T: SliderValueKind> {
    public let minimumValue: T
    public let maximumValue: T
    public let minimumValueWithOffset: T
    public let maximumValueWithOffset: T
    public let hasLowerBoundOffset: Bool
    public let hasUpperBoundOffset: Bool
    public let accessibilityStepIncrement: Int
    public let range: ClosedRange<T>
    public let values: [T]
    public let valuesWithOffsets: [T]

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
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue

        let offset: T = 1
        minimumValueWithOffset = hasLowerBoundOffset ? minimumValue - offset : minimumValue
        maximumValueWithOffset = hasUpperBoundOffset ? maximumValue + offset : maximumValue

        self.hasLowerBoundOffset = hasLowerBoundOffset
        self.hasUpperBoundOffset = hasUpperBoundOffset
        self.accessibilityStepIncrement = accessibilityStepIncrement ?? 1
        range = minimumValue ... maximumValue
        values = ([minimumValue] + stepValues + [maximumValue]).compactMap({ $0 })

        var valuesWithOffsets = values

        if hasLowerBoundOffset {
            valuesWithOffsets.insert(minimumValueWithOffset, at: 0)
        }

        if hasUpperBoundOffset {
            valuesWithOffsets.append(maximumValueWithOffset)
        }

        self.valuesWithOffsets = valuesWithOffsets
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
