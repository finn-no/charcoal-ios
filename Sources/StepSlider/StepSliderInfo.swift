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
    public let effectiveRange: ClosedRange<T>
    public let effectiveValues: [T]
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
                lowerBoundOffset: T,
                upperBoundOffset: T,
                accessibilityStepIncrement: Int? = nil) {
        range = minimumValue ... maximumValue
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        values = ([minimumValue] + stepValues + [maximumValue]).compactMap({ $0 })

        let effectiveMinimumValue = range.lowerBound - lowerBoundOffset
        let effectiveMaximumValue = range.upperBound + upperBoundOffset
        effectiveRange = effectiveMinimumValue ... effectiveMaximumValue

        var effectiveValues = [T]()

        if effectiveMinimumValue < range.lowerBound {
            effectiveValues.append(effectiveMinimumValue)
        }

        effectiveValues.append(contentsOf: values)

        if effectiveMaximumValue > range.upperBound {
            effectiveValues.append(effectiveMaximumValue)
        }

        self.effectiveValues = effectiveValues
        self.accessibilityStepIncrement = accessibilityStepIncrement ?? 1
    }

    public init(minimumValue: T,
                maximumValue: T,
                incrementedBy increment: T,
                lowerBoundOffset: T,
                upperBoundOffset: T,
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
            lowerBoundOffset: lowerBoundOffset,
            upperBoundOffset: upperBoundOffset,
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
