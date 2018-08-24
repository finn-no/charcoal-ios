//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterInfoType {
    var name: String { get }
}

public protocol SearchTermFilterInfoType: FilterInfoType {
    var value: String? { get }
    var placeholderText: String { get }
}

public protocol PreferenceValueType: ListItem {
    var name: String { get }
    var value: String { get }
    var results: Int { get }
}

// MARK: - ListItem default implementation

extension PreferenceValueType {
    public var title: String? { return name }
    public var detail: String? { return String(results) }
    public var showsDisclosureIndicator: Bool { return false }
}

public protocol PreferenceInfoType: FilterInfoType {
    var name: String { get }
    var values: [PreferenceValueType] { get }
    var isMultiSelect: Bool { get }
}

public protocol PreferenceFilterInfoType: FilterInfoType {
    var preferences: [PreferenceInfoType] { get }
}

public protocol ListSelectionFilterInfoType: FilterInfoType {
    var values: [ListSelectionFilterValueType] { get }
    var isMultiSelect: Bool { get }
}

public protocol ListSelectionFilterValueType: ListItem {
    var name: String { get }
    var results: Int { get }
    var value: String? { get }
}

// MARK: - SelectionFilterInfoType: ListItem default implementation

extension ListSelectionFilterValueType {
    public var title: String? { return name }
    public var detail: String? { return String(results) }
    public var showsDisclosureIndicator: Bool { return false }
}

public protocol MultiLevelListSelectionFilterInfoType: FilterInfoType, ListItem {
    var filters: [MultiLevelListSelectionFilterInfoType] { get }
    var isMultiSelect: Bool { get }
    var results: Int { get }
    var value: String? { get }
}

// MARK: - MultiLevelSelectionFilterInfoType: ListItem default implementation

extension MultiLevelListSelectionFilterInfoType {
    public var title: String? { return name }
    public var detail: String? { return String(results) }
    public var showsDisclosureIndicator: Bool { return filters.count > 0 }
}

public protocol RangeFilterInfoType: FilterInfoType {
    var lowValue: Int { get }
    var highValue: Int { get }
    var additionalLowerBoundOffset: Int { get }
    var additionalUpperBoundOffset: Int { get }
    var steps: Int { get }
    var unit: String { get }
    var referenceValues: [Int] { get }
    var isCurrencyValueRange: Bool { get }
    var accessibilitySteps: Int? { get }
    var accessibilityValueSuffix: String? { get }
    var usesSmallNumberInputFont: Bool { get }
    var displaysUnitInNumberInput: Bool { get }
}
