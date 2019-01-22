//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

protocol FilterConfiguration {
    func handlesVerticalId(_ vertical: String) -> Bool
    var preferenceFilterKeys: [FilterKey] { get }
    var supportedFiltersKeys: [FilterKey] { get }
    var mapFilterKey: FilterKey? { get }
    func createFilterInfoFrom(filterData: FilterData) -> FilterInfoType?
}
