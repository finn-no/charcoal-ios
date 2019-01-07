//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public protocol ListSelectionFilterInfoType: FilterInfoType {
    var values: [FilterValueType] { get }
    var isMultiSelect: Bool { get }
    var isMapFilter: Bool { get }
}
