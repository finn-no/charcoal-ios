//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class FilterInfoBuilder {
    let filter: Filter

    public init(filter: Filter) {
        self.filter = filter
    }

    public func build() -> [FilterInfoType] {
        var info = [FilterInfoType]()

        guard let market = FilterMarket(market: filter.market) else {
            return []
        }

        if filter.rawFilterKeys.contains(FilterKey.query.rawValue) {
            info.append(buildFreeSearchFilterInfo())
        }

        if let preferenceFilterInfo = buildPreferenceFilterInfo(fromKeys: market.preferenceFilterKeys) {
            info.append(preferenceFilterInfo)
        }

        let remainingFilters = buildFilterInfo(fromKeys: market.supportedFiltersKeys)
        info.append(contentsOf: remainingFilters)

        return info
    }
}

private extension FilterInfoBuilder {
    func buildFreeSearchFilterInfo() -> FilterInfoType {
        return FreeSearchFilterInfo(currentSearchQuery: nil, searchQueryPlaceholder: "Ord i annonsen", name: "freesearch")
    }

    func buildPreferenceFilterInfo(fromKeys keys: [FilterKey]) -> PreferenceFilterInfo? {
        let filterDataArray = keys.compactMap { filter.filterData(forKey: $0) }

        let preferences = filterDataArray.compactMap { filter -> PreferenceInfoType? in
            guard let values = filter.queries?.map({ PreferenceValue(name: $0.title, results: $0.totalResults) }) else {
                return nil
            }

            return PreferenceInfo(name: filter.title, values: values)
        }

        if preferences.isEmpty {
            return nil
        }

        return PreferenceFilterInfo(preferences: preferences, name: "Preferences")
    }

    func buildMultiLevelFilterInfo(from filterData: FilterData) -> MultilevelFilterInfo? {
        guard let filters = filterData.queries?.map({ query -> MultilevelFilterInfo in
            let queryFilters = query.filter?.queries.map({ filterQueries -> MultilevelFilterInfo in
                return MultilevelFilterInfo(filters: [], name: filterQueries.title, results: filterQueries.totalResults)
            })

            return MultilevelFilterInfo(filters: queryFilters ?? [], name: query.title, results: query.totalResults)
        }) else {
            return nil
        }

        return MultilevelFilterInfo(filters: filters, name: filterData.title, results: 0)
    }

    func buildFilterInfo(fromKeys keys: [FilterKey]) -> [FilterInfoType] {
        var filterInfo = [FilterInfoType]()

        keys.forEach({ key in
            guard let filterData = filter.filterData(forKey: key) else {
                return
            }

            if filterData.isRange {
                let rangeInfoFilterBuilder = RangeFilterInfoBuilder(filter: filter)
                if let rangeFilterInfo = rangeInfoFilterBuilder.buildRangeFilterInfo(from: filterData) {
                    filterInfo.append(rangeFilterInfo)
                }
            } else {
                if let mulitLevelFilterInfo = buildMultiLevelFilterInfo(from: filterData) {
                    filterInfo.append(mulitLevelFilterInfo)
                }
            }
        })

        return filterInfo
    }
}
