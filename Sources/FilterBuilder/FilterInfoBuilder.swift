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
        return FreeSearchFilterInfo(key: .query, currentSearchQuery: nil, searchQueryPlaceholder: "Ord i annonsen", name: "freesearch")
    }

    func buildPreferenceFilterInfo(fromKeys keys: [FilterKey]) -> PreferenceFilterInfo? {
        let filterDataArray = keys.compactMap { filter.filterData(forKey: $0) }

        let preferences = filterDataArray.compactMap { filter -> PreferenceInfoType? in
            guard let values = filter.queries?.map({ PreferenceValue(name: $0.title, results: $0.totalResults, value: $0.value) }) else {
                return nil
            }

            return PreferenceInfo(key: filter.key, name: filter.title, values: values)
        }

        if preferences.isEmpty {
            return nil
        }

        return PreferenceFilterInfo(preferences: preferences, name: "Preferences")
    }

    func buildSelectionListFilterInfo(from filterData: FilterData) -> ListSelectionFilterInfo? {
        guard let values = filterData.queries?.map({ ListSelectionFilterValue(name: $0.title, results: $0.totalResults, value: $0.value) }) else {
            return nil
        }

        return ListSelectionFilterInfo(key: filterData.key, name: filterData.title, values: values, isMultiSelect: true)
    }

    func buildMultiLevelListSelectionFilterInfo(from filterData: FilterData) -> MultiLevelListSelectionFilterInfo? {
        guard let filters = filterData.queries?.map({ query -> MultiLevelListSelectionFilterInfo in
            let queryFilters = query.filter?.queries.map({ filterQueries -> MultiLevelListSelectionFilterInfo in
                return MultiLevelListSelectionFilterInfo(key: filterData.key, filters: [], name: filterQueries.title, results: filterQueries.totalResults, value: filterQueries.value)
            })

            return MultiLevelListSelectionFilterInfo(key: filterData.key, filters: queryFilters ?? [], name: query.title, results: query.totalResults, value: query.value)
        }) else {
            return nil
        }

        return MultiLevelListSelectionFilterInfo(key: filterData.key, filters: filters, name: filterData.title, results: 0, value: nil)
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
            } else if FilterInfoBuilder.isMultiLevelListSelectionFilter(filterData: filterData) {
                if let mulitLevelSelectionFilterInfo = buildMultiLevelListSelectionFilterInfo(from: filterData) {
                    filterInfo.append(mulitLevelSelectionFilterInfo)
                }
            } else if FilterInfoBuilder.isListSelectionFilter(filterData: filterData) {
                if let selectionListFilterInfo = buildSelectionListFilterInfo(from: filterData) {
                    filterInfo.append(selectionListFilterInfo)
                }
            }
        })

        return filterInfo
    }
}

extension FilterInfoBuilder {
    static func isListSelectionFilter(filterData: FilterData) -> Bool {
        return hasQueriesWithFilters(filterData: filterData) == false
    }

    static func isMultiLevelListSelectionFilter(filterData: FilterData) -> Bool {
        return hasQueriesWithFilters(filterData: filterData) == true
    }

    static func hasQueriesWithFilters(filterData: FilterData) -> Bool {
        guard let queries = filterData.queries else {
            return false
        }

        let hasQueriesWithFilters = queries.reduce(false, { result, element -> Bool in
            if result == true {
                return result
            }

            if element.filter != nil {
                return true
            }

            return false
        })

        return hasQueriesWithFilters
    }
}
