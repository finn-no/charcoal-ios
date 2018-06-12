//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit
import Foundation

struct FilterInfo: FilterInfoType {
    let name: String
}

struct FreeSearchFilterInfo: FreeSearchFilterInfoType {
    var currentSearchQuery: String?
    var searchQueryPlaceholder: String
    var name: String
}

struct PreferenceFilterInfo: PreferenceFilterInfoType {
    var preferences: [PreferenceInfoType]
    var name: String
}

struct PreferenceInfo: PreferenceInfoType {
    let name: String
    let values: [PreferenceValueType]
    let isMultiSelect: Bool = true
}

struct PreferenceValue: PreferenceValueType {
    let name: String
    var results: Int
}

struct MultilevelFilterInfo: MultiLevelFilterInfoType {
    var filters: [MultiLevelFilterInfoType]
    var name: String
    let isMultiSelect: Bool = true
    let results: Int
}

struct RangeFilterInfo: RangeFilterInfoType {
    var name: String
    var lowValue: Int
    var highValue: Int
    var steps: Int
    var unit: String
}
