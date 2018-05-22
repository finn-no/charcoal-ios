//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterInfo {
    var name: String { get }
    var selectedValues: [String] { get }
}

public protocol FreeSearchFilterInfo: FilterInfo {
    var currentSearchQuery: String? { get }
    var searchQueryPlaceholder: String { get }
}

public protocol PreferenceValue: ListItem {
    var name: String { get }
    var isSelected: Bool { get }
}

// MARK: - ListItem default implementation

extension PreferenceValue {
    public var title: String? { return name }
    public var detail: String? { return nil }
    public var showsDisclosureIndicator: Bool { return false }
}

public protocol PreferenceInfo {
    var name: String { get }
    var values: [PreferenceValue] { get }
    var isMultiSelect: Bool { get }
}

public protocol PreferenceFilterInfo: FilterInfo {
    var preferences: [PreferenceInfo] { get }
}

public protocol MultiLevelFilterInfo: FilterInfo, ListItem {
    var level: Int { get }
    var filters: [MultiLevelFilterInfo] { get }
    var isMultiSelect: Bool { get }
}

// MARK: - ListItem default implementation

extension MultiLevelFilterInfo {
    public var title: String? { return name }
    public var detail: String? { return nil }
    public var showsDisclosureIndicator: Bool { return filters.count > 0 }
}
