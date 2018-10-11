//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public protocol ListSelectionFilterInfoType: FilterInfoType {
    var values: [ListSelectionFilterValueType] { get }
    var isMultiSelect: Bool { get }
}

public protocol ListSelectionFilterValueType: ListItem {
    var title: String { get }
    var results: Int { get }
    var value: String { get }
}

// MARK: - SelectionFilterInfoType: ListItem default implementation

extension ListSelectionFilterValueType {
    public var detail: String? { return String(results) }
    public var showsDisclosureIndicator: Bool { return false }
}
