//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public final class RangeFilterInfo {
    enum Kind {
        case slider
        case stepper
    }

    typealias RangeBoundsOffsets = (hasLowerBoundOffset: Bool, hasUpperBoundOffset: Bool)
    typealias AccessibilityValues = (stepIncrement: Int?, valueSuffix: String?)
    typealias AppearenceProperties = (usesSmallNumberInputFont: Bool, displaysUnitInNumberInput: Bool, isCurrencyValueRange: Bool)

    let kind: Kind
    let sliderInfo: StepSliderInfo
    let unit: String
    let isCurrencyValueRange: Bool
    let accessibilityValueSuffix: String?
    let usesSmallNumberInputFont: Bool
    let displaysUnitInNumberInput: Bool

    init(kind: Kind, lowValue: Int, highValue: Int, increment: Int, rangeBoundsOffsets: RangeBoundsOffsets, unit: String, accesibilityValues: AccessibilityValues, appearanceProperties: AppearenceProperties) {
        self.kind = kind
        self.unit = unit
        sliderInfo = StepSliderInfo(
            minimumValue: lowValue,
            maximumValue: highValue,
            incrementedBy: increment,
            hasLowerBoundOffset: rangeBoundsOffsets.hasLowerBoundOffset,
            hasUpperBoundOffset: rangeBoundsOffsets.hasUpperBoundOffset,
            accessibilityStepIncrement: accesibilityValues.stepIncrement
        )
        isCurrencyValueRange = appearanceProperties.isCurrencyValueRange
        accessibilityValueSuffix = accesibilityValues.valueSuffix
        usesSmallNumberInputFont = appearanceProperties.usesSmallNumberInputFont
        displaysUnitInNumberInput = appearanceProperties.displaysUnitInNumberInput
    }
}
