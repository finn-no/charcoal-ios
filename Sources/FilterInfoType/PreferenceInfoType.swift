//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public protocol PreferenceFilterInfoType: FilterInfoType {
    var values: [FilterValueType] { get }
    var isMultiSelect: Bool { get }
}
