//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

struct FilterInfo: FilterInfoType {
    let name: String
}

struct FreeSearchFilterInfo: FreeSearchFilterInfoType {
    var currentSearchQuery: String?
    var searchQueryPlaceholder: String
    var name: String
}

struct PreferenceFilterInfo: PreferenceFilterInfoType {
    var preferences: [PreferenceInfoType]
    var name: String
}

struct PreferenceInfo: PreferenceInfoType {
    let name: String
    let values: [PreferenceValueType]
    let isMultiSelect: Bool = true
}

struct PreferenceValue: PreferenceValueType {
    let name: String
    let results: Int
    let value: String
}

struct MultiLevelSelectionFilterInfo: MultiLevelSelectionFilterInfoType {
    let filters: [MultiLevelSelectionFilterInfoType]
    let name: String
    let isMultiSelect: Bool = true
    let results: Int
    let value: String?
}

struct RangeFilterInfo: RangeFilterInfoType {
    var name: String
    var lowValue: Int
    var highValue: Int
    var additionalLowerBoundOffset: Int
    var additionalUpperBoundOffset: Int
    var steps: Int
    var unit: String
    var referenceValues: [Int]
    var isCurrencyValueRange: Bool
    var accessibilitySteps: Int?
    var accessibilityValueSuffix: String?
    var usesSmallNumberInputFont: Bool
    var displaysUnitInNumberInput: Bool
}

extension RangeFilterInfo {
    typealias RangeBoundsOffsets = (lowerBoundOffset: Int, upperBoundOffset: Int)
    typealias ReferenceValues = [Int]
    typealias AccessibilityValues = (accessibilitySteps: Int?, accessibilityValueSuffix: String?)
    typealias AppearenceProperties = (usesSmallNumberInputFont: Bool, displaysUnitInNumberInput: Bool, isCurrencyValueRange: Bool)

    init(name: String, lowValue: Int, highValue: Int, steps: Int, rangeBoundsOffsets: RangeBoundsOffsets, unit: String, referenceValues: ReferenceValues, accesibilityValues: AccessibilityValues, appearanceProperties: AppearenceProperties) {
        self.name = name
        self.lowValue = lowValue
        self.highValue = highValue
        additionalLowerBoundOffset = rangeBoundsOffsets.lowerBoundOffset
        additionalUpperBoundOffset = rangeBoundsOffsets.upperBoundOffset
        self.steps = steps
        self.unit = unit
        self.referenceValues = referenceValues
        isCurrencyValueRange = appearanceProperties.isCurrencyValueRange
        accessibilitySteps = accesibilityValues.accessibilitySteps
        accessibilityValueSuffix = accesibilityValues.accessibilityValueSuffix
        usesSmallNumberInputFont = appearanceProperties.usesSmallNumberInputFont
        displaysUnitInNumberInput = appearanceProperties.displaysUnitInNumberInput
    }
}
