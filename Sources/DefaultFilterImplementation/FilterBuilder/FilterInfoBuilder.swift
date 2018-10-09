//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class FilterInfoBuilder {
    let filter: FilterSetup
    let selectionDataSource: ParameterBasedFilterInfoSelectionDataSource
    var multiLevelFilterLookup: [MultiLevelListSelectionFilterInfoLookupKey: MultiLevelListSelectionFilterInfo]

    public init(filter: FilterSetup, selectionDataSource: ParameterBasedFilterInfoSelectionDataSource) {
        self.filter = filter
        self.selectionDataSource = selectionDataSource
        multiLevelFilterLookup = [:]
    }

    public func build() -> [FilterInfoType] {
        multiLevelFilterLookup = [:]
        var info = [FilterInfoType]()

        guard let market = FilterMarket(market: filter.market) else {
            return []
        }

        if filter.rawFilterKeys.contains(FilterKey.query.rawValue) {
            info.append(buildSearchQueryFilterInfo())
        }

        if let preferenceFilterInfo = buildPreferenceFilterInfo(fromKeys: market.preferenceFilterKeys) {
            info.append(preferenceFilterInfo)
        }

        let remainingFilters = buildFilterInfo(fromKeys: market.supportedFiltersKeys)
        info.append(contentsOf: remainingFilters)

        selectionDataSource.multiLevelFilterLookup = multiLevelFilterLookup
        return info
    }
}

private extension FilterInfoBuilder {
    func buildSearchQueryFilterInfo() -> FilterInfoType {
        return SearchQueryFilterInfo(parameterName: "q", value: nil, placeholderText: "Ord i annonsen", title: "Filtrer søket")
    }

    func buildPreferenceFilterInfo(fromKeys keys: [FilterKey]) -> PreferenceFilterInfo? {
        let filterDataArray = keys.compactMap { filter.filterData(forKey: $0) }

        let preferences = filterDataArray.compactMap { filter -> PreferenceInfoType? in
            guard let values = filter.queries?.map({ PreferenceValue(title: $0.title, results: $0.totalResults, value: $0.value) }) else {
                return nil
            }

            return PreferenceInfo(parameterName: filter.parameterName, title: filter.title, values: values)
        }

        if preferences.isEmpty {
            return nil
        }

        return PreferenceFilterInfo(preferences: preferences, title: "Preferences")
    }

    func buildSelectionListFilterInfo(from filterData: FilterData) -> ListSelectionFilterInfo? {
        guard let values = filterData.queries?.map({ ListSelectionFilterValue(title: $0.title, results: $0.totalResults, value: $0.value) }) else {
            return nil
        }

        return ListSelectionFilterInfo(parameterName: filterData.parameterName, title: filterData.title, values: values, isMultiSelect: true)
    }

    func buildMultiLevelListSelectionFilterInfo(fromFilterData filterData: FilterData) -> MultiLevelListSelectionFilterInfo? {
        guard let filters = filterData.queries?.map({ query -> MultiLevelListSelectionFilterInfo in
            let queryFilters = buildMultiLevelListSelectionFilterInfo(fromQueryFilter: query.filter)
            let filter = MultiLevelListSelectionFilterInfo(parameterName: filterData.parameterName, title: query.title, results: query.totalResults, value: query.value)
            filter.setSubLevelFilters(queryFilters)
            multiLevelFilterLookup[filter.lookupKey] = filter
            return filter
        }) else {
            return nil
        }
        let filter = MultiLevelListSelectionFilterInfo(parameterName: filterData.parameterName, title: filterData.title, results: 0, value: "")
        filter.setSubLevelFilters(filters)
        multiLevelFilterLookup[filter.lookupKey] = filter
        return filter
    }

    func buildMultiLevelListSelectionFilterInfo(fromQueryFilter queryFilter: FilterData.Query.QueryFilter?) -> [MultiLevelListSelectionFilterInfo] {
        guard let queryFilter = queryFilter else {
            return []
        }
        let queryFilters = queryFilter.queries.map({ filterQueries -> MultiLevelListSelectionFilterInfo in
            let subQueryFilters = buildMultiLevelListSelectionFilterInfo(fromQueryFilter: filterQueries.filter)
            let filter = MultiLevelListSelectionFilterInfo(parameterName: queryFilter.parameterName, title: filterQueries.title, results: filterQueries.totalResults, value: filterQueries.value)
            filter.setSubLevelFilters(subQueryFilters)
            filter.updateSelectionState(selectionDataSource)
            multiLevelFilterLookup[filter.lookupKey] = filter
            return filter
        })
        return queryFilters
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
                if let mulitLevelSelectionFilterInfo = buildMultiLevelListSelectionFilterInfo(fromFilterData: filterData) {
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
