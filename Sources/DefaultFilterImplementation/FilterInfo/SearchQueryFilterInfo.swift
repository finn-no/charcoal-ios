//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

class SearchQueryFilterInfo: SearchQueryFilterInfoType, ParameterBasedFilterInfo {
    let parameterName: String
    var value: String?
    var placeholderText: String
    var title: String

    init(parameterName: String, value: String?, placeholderText: String, title: String) {
        self.parameterName = parameterName
        self.value = value
        self.placeholderText = placeholderText
        self.title = title
    }
}
