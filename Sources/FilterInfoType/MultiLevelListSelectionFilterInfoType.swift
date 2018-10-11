//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public protocol MultiLevelListSelectionFilterInfoType: AnyObject, FilterInfoType, ListItem {
    var filters: [MultiLevelListSelectionFilterInfoType] { get }
    var isMultiSelect: Bool { get }
    var results: Int { get }
    var value: String { get }
}

// MARK: - MultiLevelSelectionFilterInfoType: ListItem default implementation

extension MultiLevelListSelectionFilterInfoType {
    public var detail: String? { return String(results) }
    public var showsDisclosureIndicator: Bool { return filters.count > 0 }
}
