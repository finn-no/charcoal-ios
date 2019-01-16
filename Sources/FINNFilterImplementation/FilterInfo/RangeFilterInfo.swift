//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

class RangeFilterInfo: RangeFilterInfoType, ParameterBasedFilterInfo {
    typealias RangeBoundsOffsets = (lowerBoundOffset: Int, upperBoundOffset: Int)
    typealias AccessibilityValues = (accessibilitySteps: Int?, accessibilityValueSuffix: String?)
    typealias AppearenceProperties = (usesSmallNumberInputFont: Bool, displaysUnitInNumberInput: Bool, isCurrencyValueRange: Bool)

    let parameterName: String
    var title: String
    let sliderData: StepSliderData<Int>
    var unit: String
    var isCurrencyValueRange: Bool
    var accessibilitySteps: Int?
    var accessibilityValueSuffix: String?
    var usesSmallNumberInputFont: Bool
    var displaysUnitInNumberInput: Bool

    init(parameterName: String, title: String, lowValue: Int, highValue: Int, increment: Int, rangeBoundsOffsets: RangeBoundsOffsets, unit: String, accesibilityValues: AccessibilityValues, appearanceProperties: AppearenceProperties) {
        self.parameterName = parameterName
        self.title = title
        self.unit = unit
        sliderData = StepSliderData(
            minimumValue: lowValue,
            maximumValue: highValue,
            incrementedBy: increment,
            lowerBoundOffset: rangeBoundsOffsets.lowerBoundOffset,
            upperBoundOffset: rangeBoundsOffsets.upperBoundOffset
        )
        isCurrencyValueRange = appearanceProperties.isCurrencyValueRange
        accessibilitySteps = accesibilityValues.accessibilitySteps
        accessibilityValueSuffix = accesibilityValues.accessibilityValueSuffix
        usesSmallNumberInputFont = appearanceProperties.usesSmallNumberInputFont
        displaysUnitInNumberInput = appearanceProperties.displaysUnitInNumberInput
    }
}
