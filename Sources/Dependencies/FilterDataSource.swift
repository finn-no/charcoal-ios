//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterDataSource {
    var verticals: [Vertical] { get }
    var filterInfo: [FilterInfoType] { get }
    var numberOfHits: Int { get }
    var filterTitle: String { get }

    func selectionValueTitlesForFilterInfoAndSubFilters(at index: Int) -> [String]
}
