//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

class PreferenceFilterInfo: PreferenceFilterInfoType {
    let preferences: [PreferenceInfoType]
    let title: String

    init(preferences: [PreferenceInfoType], title: String) {
        self.preferences = preferences
        self.title = title
    }
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
