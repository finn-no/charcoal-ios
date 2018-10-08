//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

enum SelectionState {
    case none
    case partial
    case selected
}

public protocol ParameterBasedFilterInfo: AnyObject, FilterInfoType {
    var parameterName: String { get }
}

class SearchQueryFilterInfo: SearchQueryFilterInfoType, ParameterBasedFilterInfo {
    let parameterName: String
    var value: String?
    var placeholderText: String
    var title: String

    init(parameterName: String, value: String?, placeholderText: String, title: String) {
        self.parameterName = parameterName
        self.value = value
        self.placeholderText = placeholderText
        self.title = title
    }
}

struct PreferenceFilterInfo: PreferenceFilterInfoType {
    var preferences: [PreferenceInfoType]
    var title: String
}

class PreferenceInfo: PreferenceInfoType, ParameterBasedFilterInfo {
    let parameterName: String
    let title: String
    let values: [PreferenceValueType]
    let isMultiSelect: Bool
    var preferenceName: String { return title }

    init(parameterName: String, title: String, values: [PreferenceValueType], isMultiSelect: Bool = true) {
        self.parameterName = parameterName
        self.title = title
        self.values = values
        self.isMultiSelect = isMultiSelect
    }
}

struct PreferenceValue: PreferenceValueType {
    let title: String
    let results: Int
    let value: String
}

class ListSelectionFilterInfo: ListSelectionFilterInfoType, ParameterBasedFilterInfo {
    let parameterName: String
    let title: String
    let values: [ListSelectionFilterValueType]
    let isMultiSelect: Bool

    init(parameterName: String, title: String, values: [ListSelectionFilterValueType], isMultiSelect: Bool) {
        self.parameterName = parameterName
        self.title = title
        self.values = values
        self.isMultiSelect = isMultiSelect
    }
}

struct ListSelectionFilterValue: ListSelectionFilterValueType {
    let title: String
    let results: Int
    let value: String
}

class MultiLevelListSelectionFilterInfo: MultiLevelListSelectionFilterInfoType, ParameterBasedFilterInfo {
    let parameterName: String
    private(set) var filters: [MultiLevelListSelectionFilterInfoType]
    let title: String
    let isMultiSelect: Bool
    let results: Int
    let value: String
    private(set) weak var parent: MultiLevelListSelectionFilterInfoType?
    private(set) var selectionState: SelectionState

    init(parameterName: String, title: String, isMultiSelect: Bool = true, results: Int, value: String) {
        self.parameterName = parameterName
        self.title = title
        self.isMultiSelect = isMultiSelect
        self.results = results
        self.value = value
        selectionState = .none
        filters = []
    }

    func setSubLevelFilters(_ subLevels: [MultiLevelListSelectionFilterInfo]) {
        filters = subLevels
        subLevels.forEach({ $0.parent = self })
    }

    private func childFilterHasPartialSelectionState() -> Bool {
        return filters.contains(where: { (filterInfoType) -> Bool in
            if let filterInfo = filterInfoType as? MultiLevelListSelectionFilterInfo {
                return filterInfo.selectionState == .partial
            }
            return false
        })
    }

    private func numberOfChildFilterWithFullSelectionState() -> Int {
        return filters.filter({ (filterInfoType) -> Bool in
            if let filterInfo = filterInfoType as? MultiLevelListSelectionFilterInfo {
                return filterInfo.selectionState == .selected
            }
            return false
        }).count
    }

    func updateSelectionState(_ selectionDataSource: ParameterBasedFilterInfoSelectionDataSource) {
        if childFilterHasPartialSelectionState() {
            selectionState = .partial
        } else if filters.count > 0 {
            let childsWithFullSelection = numberOfChildFilterWithFullSelectionState()
            if childsWithFullSelection == filters.count {
                selectionState = .selected
            } else if childsWithFullSelection > 0 {
                selectionState = .partial
            }
        } else if let _ = selectionDataSource.value(for: self) {
            selectionState = .selected
        }
    }
}

extension MultiLevelListSelectionFilterInfo: CustomDebugStringConvertible {
    var debugDescription: String {
        return "<\(type(of: self)): \(Unmanaged.passUnretained(self).toOpaque())> parameter: \(parameterName), title: \(title), subfilters: \(filters.count)"
    }
}

class RangeFilterInfo: RangeFilterInfoType, ParameterBasedFilterInfo {
    typealias RangeBoundsOffsets = (lowerBoundOffset: Int, upperBoundOffset: Int)
    typealias ReferenceValues = [Int]
    typealias AccessibilityValues = (accessibilitySteps: Int?, accessibilityValueSuffix: String?)
    typealias AppearenceProperties = (usesSmallNumberInputFont: Bool, displaysUnitInNumberInput: Bool, isCurrencyValueRange: Bool)

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
