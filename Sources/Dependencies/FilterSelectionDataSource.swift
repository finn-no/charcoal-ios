//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public struct FilterSelectionData {
    public let filter: FilterInfoType
    public let value: FilterSelectionValue
}

public protocol FilterSelectionDataSource: AnyObject {
    func value(for filterInfo: FilterInfoType) -> FilterSelectionValue?
    func valueAndSubLevelValues(for filterInfo: FilterInfoType) -> [FilterSelectionData]
    func setValue(_ filterSelectionValue: FilterSelectionValue?, for filterInfo: FilterInfoType)
}
