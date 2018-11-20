//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

class FilterValue: FilterValueType, NumberOfHitsCompatible {
    let title: String
    let results: Int
    let value: String
    let parameterName: String
    var parentFilterInfo: FilterInfoType?
    var lookupKey: FilterValueUniqueKey {
        return FilterValueUniqueKey(parameterName: parameterName, value: value)
    }

    init(title: String, results: Int, value: String, parameterName: String, parentFilterInfo: FilterInfoType? = nil) {
        self.title = title
        self.results = results
        self.value = value
        self.parameterName = parameterName
        self.parentFilterInfo = parentFilterInfo
    }
}
