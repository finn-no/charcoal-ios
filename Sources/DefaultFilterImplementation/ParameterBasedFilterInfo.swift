//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public protocol ParameterBasedFilterInfo {
    var parameterName: String { get }
}

struct SearchQueryFilterInfo: SearchQueryFilterInfoType, ParameterBasedFilterInfo {
    let parameterName: String
    var value: String?
    var placeholderText: String
    var title: String
}

struct PreferenceFilterInfo: PreferenceFilterInfoType {
    var preferences: [PreferenceInfoType]
    var title: String
}

struct PreferenceInfo: PreferenceInfoType, ParameterBasedFilterInfo {
    let parameterName: String
    let title: String
    let values: [PreferenceValueType]
    let isMultiSelect: Bool = true
    var preferenceName: String { return title }
}

struct PreferenceValue: PreferenceValueType {
    let title: String
    let results: Int
    let value: String
}

struct ListSelectionFilterInfo: ListSelectionFilterInfoType, ParameterBasedFilterInfo {
    let parameterName: String
    let title: String
    let values: [ListSelectionFilterValueType]
    let isMultiSelect: Bool
}

struct ListSelectionFilterValue: ListSelectionFilterValueType {
    let title: String
    let results: Int
    let value: String
}

struct MultiLevelListSelectionFilterInfo: MultiLevelListSelectionFilterInfoType, ParameterBasedFilterInfo {
    let parameterName: String
    let filters: [MultiLevelListSelectionFilterInfoType]
    let title: String
    let isMultiSelect: Bool = true
    let results: Int
    let value: String
}

struct RangeFilterInfo: RangeFilterInfoType, ParameterBasedFilterInfo {
    let parameterName: String
    var title: String
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

    init(parameterName: String, title: String, lowValue: Int, highValue: Int, steps: Int, rangeBoundsOffsets: RangeBoundsOffsets, unit: String, referenceValues: ReferenceValues, accesibilityValues: AccessibilityValues, appearanceProperties: AppearenceProperties) {
        self.parameterName = parameterName
        self.title = title
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
