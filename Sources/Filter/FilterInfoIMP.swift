//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public protocol KeyedFilterInfo {
    var key: FilterKey { get }
}

struct SearchQueryFilterInfo: SearchQueryFilterInfoType, KeyedFilterInfo {
    var key: FilterKey
    var value: String?
    var placeholderText: String
    var name: String
}

struct PreferenceFilterInfo: PreferenceFilterInfoType {
    var preferences: [PreferenceInfoType]
    var name: String
}

struct PreferenceInfo: PreferenceInfoType, KeyedFilterInfo {
    var key: FilterKey
    let preferenceName: String
    let values: [PreferenceValueType]
    let isMultiSelect: Bool = true
    var name: String { return "" } // This will be title later
}

struct PreferenceValue: PreferenceValueType {
    let preferenceName: String
    let results: Int
    let value: String
}

struct ListSelectionFilterInfo: ListSelectionFilterInfoType, KeyedFilterInfo {
    var key: FilterKey
    let name: String
    let values: [ListSelectionFilterValueType]
    let isMultiSelect: Bool
}

struct ListSelectionFilterValue: ListSelectionFilterValueType {
    let title: String
    let results: Int
    let value: String?
}

struct MultiLevelListSelectionFilterInfo: MultiLevelListSelectionFilterInfoType, KeyedFilterInfo {
    var key: FilterKey
    let filters: [MultiLevelListSelectionFilterInfoType]
    let name: String
    let isMultiSelect: Bool = true
    let results: Int
    let value: String?
}

struct RangeFilterInfo: RangeFilterInfoType, KeyedFilterInfo {
    var key: FilterKey
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

    init(key: FilterKey, name: String, lowValue: Int, highValue: Int, steps: Int, rangeBoundsOffsets: RangeBoundsOffsets, unit: String, referenceValues: ReferenceValues, accesibilityValues: AccessibilityValues, appearanceProperties: AppearenceProperties) {
        self.key = key
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
