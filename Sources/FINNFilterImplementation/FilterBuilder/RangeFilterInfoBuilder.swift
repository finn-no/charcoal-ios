//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class RangeFilterInfoBuilder {
    let filter: FilterSetup

    init(filter: FilterSetup) {
        self.filter = filter
    }

    func buildRangeFilterInfo(from filterData: FilterData) -> FilterInfoType? {
        guard let market = FilterMarket(market: filter.market) else {
            return nil
        }

        return market.createFilterInfoFrom(filterData: filterData)
    }
}
