//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterDataSource {
    var searchQuery: SearchQueryFilterInfoType? { get }
    var verticals: [Vertical] { get }
    var preferences: [PreferenceFilterInfoType] { get }
    var filters: [FilterInfoType] { get }
    var numberOfHits: Int { get }
    var filterTitle: String { get }
    func numberOfHits(for filterValue: FilterValueType) -> Int
}
