//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

class PreferenceFilterInfo: PreferenceFilterInfoType, ParameterBasedFilterInfo {
    let parameterName: String
    let title: String
    let values: [FilterValueType]
    let isMultiSelect: Bool

    init(parameterName: String, title: String, values: [FilterValueType], isMultiSelect: Bool = true) {
        self.parameterName = parameterName
        self.title = title
        self.values = values
        self.isMultiSelect = isMultiSelect

        values.compactMap({ return $0 as? FilterValue }).forEach({ $0.parentFilterInfo = self })
    }
}
