//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class RangeFilterInfoBuilder {
    let filter: Filter

    init(filter: Filter) {
        self.filter = filter
    }

    func buildRangeFilterInfo(from filterData: FilterData) -> RangeFilterInfoType? {
        guard let market = FilterMarket(market: filter.market) else {
            return nil
        }

        switch market {
        case .bap:
            return buildRangeFilterInfoForBAPMarket(from: filterData)
        case .car:
            return buildRangeFilterInfoForCarMarket(from: filterData)
        case .realestate:
            return buildRangeFilterInfoForRealestateMarket(from: filterData)
        }
    }
}

private extension RangeFilterInfoBuilder {
    func buildRangeFilterInfoForCarMarket(from filterData: FilterData) -> RangeFilterInfoType? {
        let title = filterData.title
        let lowValue: Int
        let highValue: Int
        let steps: Int
        let unit: String

        switch filterData.key {
        case .year:
            lowValue = 1950
            let currentYear = Calendar.current.component(.year, from: Date())
            highValue = currentYear
            steps = highValue - lowValue
            unit = "år"
        case .engineEffect:
            lowValue = 0
            highValue = 500
            steps = 100
            unit = "hk"
        case .mileage:
            lowValue = 0
            highValue = 200_000
            steps = 200
            unit = "km"
        case .numberOfSeats:
            lowValue = 0
            highValue = 10
            steps = 10
            unit = "seter"
        case .price:
            lowValue = 0
            highValue = 500_000
            steps = 500
            unit = "kr"
        default:
            return nil
        }

        return RangeFilterInfo(name: title, lowValue: lowValue, highValue: highValue, steps: steps, unit: unit)
    }

    func buildRangeFilterInfoForRealestateMarket(from filterData: FilterData) -> RangeFilterInfoType? {
        let title = filterData.title
        let lowValue: Int
        let highValue: Int
        let steps: Int
        let unit: String

        switch filterData.key {
        case .price, .priceCollective:
            lowValue = 0
            highValue = 10_000_000
            steps = 100
            unit = "kr"
        case .rent:
            lowValue = 0
            highValue = 20000
            steps = 200
            unit = "kr"
        case .noOfBedrooms:
            lowValue = 0
            highValue = 6
            steps = 6
            unit = ""
        case .area:
            lowValue = 0
            highValue = 400
            steps = 80
            unit = "m\u{00B2}"
        case .plotArea:
            lowValue = 0
            highValue = 6000
            steps = 80
            unit = "m\u{00B2}"
        case .constructionYear:
            lowValue = 1900
            highValue = 2018
            steps = highValue - lowValue
            unit = ""
        default:
            return nil
        }

        return RangeFilterInfo(name: title, lowValue: lowValue, highValue: highValue, steps: steps, unit: unit)
    }

    func buildRangeFilterInfoForBAPMarket(from filterData: FilterData) -> RangeFilterInfoType? {
        let title = filterData.title
        let lowValue: Int
        let highValue: Int
        let steps: Int
        let unit: String

        switch filterData.key {
        case .price:
            lowValue = 0
            highValue = 30000
            steps = 300
            unit = "kr"
        default:
            return nil
        }

        return RangeFilterInfo(name: title, lowValue: lowValue, highValue: highValue, steps: steps, unit: unit)
    }
}
