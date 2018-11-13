//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

class ListSelectionFilterInfo: ListSelectionFilterInfoType, ParameterBasedFilterInfo {
    let parameterName: String
    let title: String
    let values: [ListSelectionFilterValueType]
    let isMultiSelect: Bool

    init(parameterName: String, title: String, values: [ListSelectionFilterValueType], isMultiSelect: Bool) {
        self.parameterName = parameterName
        self.title = title
        self.values = values
        self.isMultiSelect = isMultiSelect
    }
}

struct ListSelectionFilterValue: ListSelectionFilterValueType {
    let title: String
    let results: Int
    let value: String
}
