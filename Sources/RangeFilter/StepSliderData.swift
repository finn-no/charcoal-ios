//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public typealias SliderValueKind = Comparable & Numeric

public struct StepSliderData<T: SliderValueKind> {
    public let minimumValue: T
    public let maximumValue: T
    public let values: [T]
    public let range: ClosedRange<T>
    public let effectiveRange: ClosedRange<T>
    public let effectiveValues: [T]

    public var steps: Int {
        var additionalSteps = 0
        additionalSteps += range.lowerBound != effectiveRange.lowerBound ? 1 : 0
        additionalSteps += range.upperBound != effectiveRange.upperBound ? 1 : 0

        return values.count
    }

    public init(minimumValue: T, maximumValue: T, stepValues: [T], lowerBoundOffset: T, upperBoundOffset: T) {
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        values = ([minimumValue] + stepValues + [maximumValue]).compactMap({ $0 })
        range = minimumValue ... maximumValue

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
    }

    func isLowValueInValidRange(_ lowValue: T) -> Bool {
        if lowValue >= range.lowerBound {
            if lowValue == 0 && range.lowerBound == 0 {
                return false
            }
            return true
        }
        return false
    }

    func isHighValueInValidRange(_ highValue: T) -> Bool {
        return highValue <= range.upperBound
    }
}
