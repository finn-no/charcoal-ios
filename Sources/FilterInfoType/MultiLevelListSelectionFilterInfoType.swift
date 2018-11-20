//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public protocol MultiLevelListSelectionFilterInfoType: AnyObject, FilterInfoType, FilterValueType {
    var filters: [MultiLevelListSelectionFilterInfoType] { get }
    var isMultiSelect: Bool { get }
    var results: Int { get }
    var value: String { get }
    var hasParent: Bool { get }
}
