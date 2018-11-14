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

        values.compactMap({ return $0 as? FilterValue }).forEach({ $0.parentFilterInfo = self })
    }
}

class FilterValue: ListSelectionFilterValueType, PreferenceValueType {
    let title: String
    let results: Int
    let value: String
    var parentFilterInfo: FilterInfoType?

    init(title: String, results: Int, value: String, parentFilterInfo: FilterInfoType? = nil) {
        self.title = title
        self.results = results
        self.value = value
        self.parentFilterInfo = parentFilterInfo
    }
}

// MARK: - ListItem default implementation

extension FilterValue {
    public var detail: String? { return String(results) }
    public var showsDisclosureIndicator: Bool { return false }
}
