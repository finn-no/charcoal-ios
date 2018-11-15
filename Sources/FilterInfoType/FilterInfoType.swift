//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterInfoType {
    var title: String { get }
}

public struct FilterValueUniqueKey: Hashable {
    private let parameterName: String
    private let value: String

    public init(parameterName: String, value: String) {
        self.parameterName = parameterName
        self.value = value
    }
}

public protocol FilterValueType {
    var parentFilterInfo: FilterInfoType? { get }
    var title: String { get }
    var results: Int { get }
    var value: String { get }
    var lookupKey: FilterValueUniqueKey { get }
}
