//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterInfoType {
    var title: String { get }
}

public protocol FilterValueType: ListItem {
    var parentFilterInfo: FilterInfoType? { get }
    var title: String { get }
    var results: Int { get }
    var value: String { get }
}
