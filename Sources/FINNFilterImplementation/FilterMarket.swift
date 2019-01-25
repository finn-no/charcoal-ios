//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

enum FilterMarket {
    case bap(FilterMarketBap)
    case realestate(FilterMarketRealestate)
    case car(FilterMarketCar)
    case mc(FilterMarketMC)
    case job(FilterMarketJob)
    case boat(FilterMarketBoat)

    init?(market: String) {
        guard let market = FilterMarket.allCases.first(where: { $0.handlesVerticalId(market) }) else {
            return nil
        }

        self = market
    }

    private var currentFilterConfig: FilterConfiguration {
        switch self {
        case let .bap(bap):
            return bap
        case let .realestate(realestate):
            return realestate
        case let .car(car):
            return car
        case let .mc(mc):
            return mc
        case let .job(job):
            return job
        case let .boat(boat):
            return boat
        }
    }
}

// MARK: - FilterConfiguration

extension FilterMarket: FilterConfiguration {
    func handlesVerticalId(_ vertical: String) -> Bool {
        return currentFilterConfig.handlesVerticalId(vertical)
    }

    var preferenceFilterKeys: [FilterKey] {
        return currentFilterConfig.preferenceFilterKeys
    }

    var supportedFiltersKeys: [FilterKey] {
        return currentFilterConfig.supportedFiltersKeys
    }

    var mapFilterKey: FilterKey? {
        return currentFilterConfig.mapFilterKey
    }

    func createFilterInfoFrom(rangeFilterData: FilterData) -> FilterInfoType? {
        return currentFilterConfig.createFilterInfoFrom(rangeFilterData: rangeFilterData)
    }
}

// MARK: - CaseIterable

extension FilterMarket: CaseIterable {
    static var allCases: [FilterMarket] {
        return FilterMarketBap.allCases.map(FilterMarket.bap)
            + FilterMarketRealestate.allCases.map(FilterMarket.realestate)
            + FilterMarketCar.allCases.map(FilterMarket.car)
            + FilterMarketMC.allCases.map(FilterMarket.mc)
            + FilterMarketJob.allCases.map(FilterMarket.job)
            + FilterMarketBoat.allCases.map(FilterMarket.boat)
    }
}
