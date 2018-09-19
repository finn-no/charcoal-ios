//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterDataSource {
    var filterInfo: [FilterInfoType] { get }
    var numberOfHits: Int { get }
    var filterTitle: String { get }

    func selectionValuesForFilterInfoAndSubFilters(at index: Int) -> [String]
}
