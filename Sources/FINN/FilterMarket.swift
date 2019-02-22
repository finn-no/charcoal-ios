//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public enum FilterMarket {
    case bap(FilterMarketBap)
    case realestate(FilterMarketRealestate)
    case car(FilterMarketCar)
    case mc(FilterMarketMC)
    case job(FilterMarketJob)
    case boat(FilterMarketBoat)
    case b2b(FilterMarketB2B)

    public init?(market: String) {
        guard let market = FilterMarket.allCases.first(where: { $0.handlesVerticalId(market) }) else {
            return nil
        }

        self = market
    }

    private var currentFilterConfig: FINNFilterConfiguration {
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
        case let .b2b(b2b):
            return b2b
        }
    }
}

// MARK: - FilterConfiguration

extension FilterMarket: FilterConfiguration {
    public var preferenceFilters: [String] {
        return currentFilterConfig.preferenceFilters
    }

    public var rootLevelFilters: [String] {
        return currentFilterConfig.rootLevelFilters
    }

    public var contextFilters: Set<String> {
        return currentFilterConfig.contextFilters
    }

    public var mutuallyExclusiveFilters: Set<String> {
        return currentFilterConfig.mutuallyExclusiveFilters
    }

    public var searchFilter: String? {
        return currentFilterConfig.searchFilter
    }

    public var preferencesFilter: String? {
        return currentFilterConfig.preferencesFilter
    }

    public func handlesVerticalId(_ vertical: String) -> Bool {
        return currentFilterConfig.handlesVerticalId(vertical)
    }

    public func rangeViewModel(forKey key: String) -> RangeFilterInfo? {
        return currentFilterConfig.rangeViewModel(forKey: key)
    }
}

// MARK: - CaseIterable

extension FilterMarket: CaseIterable {
    private static var allB2BMarkets: [FilterMarket] {
        return FilterMarketB2B.allCases.map(FilterMarket.b2b)
    }

    private static var allBapMarkets: [FilterMarket] {
        return FilterMarketBap.allCases.map(FilterMarket.bap)
    }

    private static var allBoatMarkets: [FilterMarket] {
        return FilterMarketBoat.allCases.map(FilterMarket.boat)
    }

    private static var allCarMarkets: [FilterMarket] {
        return FilterMarketCar.allCases.map(FilterMarket.car)
    }

    private static var allJobMarkets: [FilterMarket] {
        return FilterMarketJob.allCases.map(FilterMarket.job)
    }

    private static var allMCMarkets: [FilterMarket] {
        return FilterMarketMC.allCases.map(FilterMarket.mc)
    }

    private static var allRealestateMarkets: [FilterMarket] {
        return FilterMarketRealestate.allCases.map(FilterMarket.realestate)
    }

    public static var allCases: [FilterMarket] {
        return allB2BMarkets + allBapMarkets + allBoatMarkets + allCarMarkets + allJobMarkets + allMCMarkets + allRealestateMarkets
    }
}
