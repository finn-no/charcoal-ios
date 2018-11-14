//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public protocol PreferenceFilterInfoType: FilterInfoType {
    var preferenceName: String { get }
    var values: [PreferenceValueType] { get }
    var isMultiSelect: Bool { get }
}

public protocol PreferenceValueType: ListItem {
    var title: String { get }
    var value: String { get }
    var results: Int { get }
}

// MARK: - ListItem default implementation

extension PreferenceValueType {
    public var detail: String? { return String(results) }
    public var showsDisclosureIndicator: Bool { return false }
}
