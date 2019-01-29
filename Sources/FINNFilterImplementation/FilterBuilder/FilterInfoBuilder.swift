//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public typealias FilterValueWithNumberOfHitsType = FilterValueType & NumberOfHitsCompatible

public struct FilterInfoBuilderResult {
    public let searchQuery: SearchQueryFilterInfoType?
    public let preferences: [PreferenceFilterInfoType]
    public let filters: [FilterInfoType]
    public let filterValueLookup: [FilterValueUniqueKey: FilterValueWithNumberOfHitsType]
}

public final class FilterInfoBuilder {
    private let filter: FilterSetup
    private let selectionDataSource: ParameterBasedFilterInfoSelectionDataSource

    public init(filter: FilterSetup, selectionDataSource: ParameterBasedFilterInfoSelectionDataSource) {
        self.filter = filter
        self.selectionDataSource = selectionDataSource
    }

    public func build() -> FilterInfoBuilderResult? {
        guard let market = FilterMarket(market: filter.market) else {
            return nil
        }

        let searchQuery: SearchQueryFilterInfoType?
        if filter.rawFilterKeys.contains(FilterKey.query.rawValue) {
            searchQuery = buildSearchQueryFilterInfo()
        } else {
            searchQuery = nil
        }
        var lookup = [FilterValueUniqueKey: FilterValueWithNumberOfHitsType]()

        let preferences = buildPreferenceFilterInfo(fromKeys: market.preferenceFilterKeys, addValuesTo: &lookup)

        let filters = buildFilterInfo(fromKeys: market.supportedFiltersKeys, mapKey: market.mapFilterKey, addValuesTo: &lookup)

        selectionDataSource.multiLevelFilterLookup = lookup
        return FilterInfoBuilderResult(searchQuery: searchQuery, preferences: preferences, filters: filters, filterValueLookup: lookup)
    }
}

private extension FilterInfoBuilder {
    func buildSearchQueryFilterInfo() -> SearchQueryFilterInfoType {
        return SearchQueryFilterInfo(parameterName: "q", placeholderText: "Ord i annonsen", title: "Filtrer søket")
    }

    func buildPreferenceFilterInfo(fromKeys keys: [FilterKey], addValuesTo lookup: inout [FilterValueUniqueKey: FilterValueWithNumberOfHitsType]) -> [PreferenceFilterInfoType] {
        let filterDataArray = keys.compactMap { filter.filterData(forKey: $0) }

        let preferences = filterDataArray.compactMap { filter -> PreferenceFilterInfoType? in
            let values = filter.queries.map({ FilterValue(title: $0.title, results: $0.totalResults, value: $0.value, parameterName: filter.parameterName) })
            values.forEach({ lookup[$0.lookupKey] = $0 })

            return PreferenceFilterInfo(parameterName: filter.parameterName, title: filter.title, values: values)
        }

        return preferences
    }

    func buildSelectionListFilterInfo(from filterData: FilterData, isMapFilter: Bool, addValuesTo lookup: inout [FilterValueUniqueKey: FilterValueWithNumberOfHitsType]) -> ListSelectionFilterInfo? {
        let values = filterData.queries.map({ FilterValue(title: $0.title, results: $0.totalResults, value: $0.value, parameterName: filterData.parameterName) })
        values.forEach({ lookup[$0.lookupKey] = $0 })

        return ListSelectionFilterInfo(parameterName: filterData.parameterName, title: filterData.title, values: values, isMultiSelect: true, isMapFilter: isMapFilter)
    }

    func buildMultiLevelListSelectionFilterInfo(fromFilterData filterData: FilterData, isMapFilter: Bool, addValuesTo lookup: inout [FilterValueUniqueKey: FilterValueWithNumberOfHitsType]) -> MultiLevelListSelectionFilterInfo? {
        let filters = filterData.queries.map({ query -> MultiLevelListSelectionFilterInfo in
            let queryFilters = buildMultiLevelListSelectionFilterInfo(fromQueryFilter: query.filter, addValuesTo: &lookup)
            let filter = MultiLevelListSelectionFilterInfo(parameterName: filterData.parameterName, title: query.title, isMultiSelect: true, results: query.totalResults, value: query.value)
            filter.setSubLevelFilters(queryFilters)
            lookup[filter.lookupKey] = filter
            selectionDataSource.updateSelectionStateForFilter(filter)
            return filter
        })

        let filter = MultiLevelListSelectionFilterInfo(parameterName: filterData.parameterName, title: filterData.title, isMultiSelect: true, results: 0, value: "", isMapFilter: isMapFilter)
        filter.setSubLevelFilters(filters)
        lookup[filter.lookupKey] = filter
        selectionDataSource.updateSelectionStateForFilter(filter)
        return filter
    }

    func buildMultiLevelListSelectionFilterInfo(fromQueryFilter queryFilter: FilterData?, addValuesTo lookup: inout [FilterValueUniqueKey: FilterValueWithNumberOfHitsType]) -> [MultiLevelListSelectionFilterInfo] {
        guard let queryFilter = queryFilter else {
            return []
        }
        let queryFilters = queryFilter.queries.map({ filterQueries -> MultiLevelListSelectionFilterInfo in
            let subQueryFilters = buildMultiLevelListSelectionFilterInfo(fromQueryFilter: filterQueries.filter, addValuesTo: &lookup)
            let filter = MultiLevelListSelectionFilterInfo(parameterName: queryFilter.parameterName, title: filterQueries.title, isMultiSelect: true, results: filterQueries.totalResults, value: filterQueries.value)
            filter.setSubLevelFilters(subQueryFilters)
            lookup[filter.lookupKey] = filter
            selectionDataSource.updateSelectionStateForFilter(filter)
            return filter
        })
        return queryFilters
    }

    func buildFilterInfo(fromKeys keys: [FilterKey], mapKey: FilterKey?, addValuesTo lookup: inout [FilterValueUniqueKey: FilterValueWithNumberOfHitsType]) -> [FilterInfoType] {
        guard let market = FilterMarket(market: filter.market) else { return [] }
        var filterInfoArray = [FilterInfoType]()

        keys.forEach({ key in
            guard let filterInfo = self.filterInfo(for: key, mapKey: mapKey, lookup: &lookup) else {
                return
            }
            filterInfoArray.append(filterInfo)

            let contextFilterKeys = market.contextFilterKeys(for: key)
            contextFilterKeys.forEach({ contextFilterKey in
                guard var contextFilterInfo = self.filterInfo(for: contextFilterKey, mapKey: mapKey, lookup: &lookup) else {
                    return
                }
                contextFilterInfo.isContextFilter = true
                filterInfoArray.append(contextFilterInfo)
            })
        })

        return filterInfoArray
    }

    private func filterInfo(for key: FilterKey, mapKey: FilterKey?, lookup: inout [FilterValueUniqueKey: FilterValueWithNumberOfHitsType]) -> FilterInfoType? {
        guard let filterData = filter.filterData(forKey: key), let market = FilterMarket(market: filter.market) else {
            return nil
        }

        if let isRange = filterData.isRange, isRange {
            return market.createFilterInfoFrom(rangeFilterData: filterData)
        } else if FilterInfoBuilder.isMultiLevelListSelectionFilter(filterData: filterData) {
            return buildMultiLevelListSelectionFilterInfo(fromFilterData: filterData, isMapFilter: key == mapKey, addValuesTo: &lookup)
        } else if FilterInfoBuilder.isListSelectionFilter(filterData: filterData) {
            return buildSelectionListFilterInfo(from: filterData, isMapFilter: key == mapKey, addValuesTo: &lookup)
        }
        return nil
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
        let queries = filterData.queries

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
