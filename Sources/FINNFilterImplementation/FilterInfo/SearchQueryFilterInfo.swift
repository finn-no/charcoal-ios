//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

class SearchQueryFilterInfo: SearchQueryFilterInfoType, ParameterBasedFilterInfo {
    let parameterName: String
    var placeholderText: String
    var title: String
    var isContextFilter: Bool = false

    init(parameterName: String, placeholderText: String, title: String) {
        self.parameterName = parameterName
        self.placeholderText = placeholderText
        self.title = title
    }
}
