//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class FilterInfoBuilder {
    private let filter: FilterSetup
    private let selectionDataSource: ParameterBasedFilterInfoSelectionDataSource
    private(set) var multiLevelFilterLookup: [MultiLevelListSelectionFilterInfo.LookupKey: MultiLevelListSelectionFilterInfo]

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

    func buildStepperFilterInfo(from filterData: FilterData) -> StepperFilterInfoType {
        return StepperFilterInfo(unit: "soverom", steps: 1, lowerLimit: 0, upperLimit: 6, title: filterData.title, parameterName: filterData.parameterName)
    }

    func buildPreferenceFilterInfo(fromKeys keys: [FilterKey]) -> PreferenceFilterInfo? {
        let filterDataArray = keys.compactMap { filter.filterData(forKey: $0) }

        let preferences = filterDataArray.compactMap { filter -> PreferenceInfoType? in
            let values = filter.queries.map({ PreferenceValue(title: $0.title, results: $0.totalResults, value: $0.value) })

            return PreferenceInfo(parameterName: filter.parameterName, title: filter.title, values: values)
        }

        if preferences.isEmpty {
            return nil
        }

        return PreferenceFilterInfo(preferences: preferences, title: "Preferences")
    }

    func buildSelectionListFilterInfo(from filterData: FilterData) -> ListSelectionFilterInfo? {
        let values = filterData.queries.map({ ListSelectionFilterValue(title: $0.title, results: $0.totalResults, value: $0.value) })

        return ListSelectionFilterInfo(parameterName: filterData.parameterName, title: filterData.title, values: values, isMultiSelect: true)
    }

    func buildMultiLevelListSelectionFilterInfo(fromFilterData filterData: FilterData) -> MultiLevelListSelectionFilterInfo? {
        guard let filterKey = FilterKey(stringValue: filterData.parameterName) else {
            return nil
        }
        let filters = filterData.queries.map({ query -> MultiLevelListSelectionFilterInfo in
            let queryFilters = buildMultiLevelListSelectionFilterInfo(fromQueryFilter: query.filter)
            let filter = MultiLevelListSelectionFilterInfo(parameterName: filterData.parameterName, title: query.title, isMultiSelect: filterKey != .category, results: query.totalResults, value: query.value)
            filter.setSubLevelFilters(queryFilters)
            multiLevelFilterLookup[filter.lookupKey] = filter
            selectionDataSource.updateSelectionStateForFilter(filter)
            return filter
        })

        let filter = MultiLevelListSelectionFilterInfo(parameterName: filterData.parameterName, title: filterData.title, isMultiSelect: filterKey != .category, results: 0, value: "")
        filter.setSubLevelFilters(filters)
        multiLevelFilterLookup[filter.lookupKey] = filter
        selectionDataSource.updateSelectionStateForFilter(filter)
        return filter
    }

    func buildMultiLevelListSelectionFilterInfo(fromQueryFilter queryFilter: FilterData?) -> [MultiLevelListSelectionFilterInfo] {
        guard let queryFilter = queryFilter else {
            return []
        }
        let queryFilters = queryFilter.queries.map({ filterQueries -> MultiLevelListSelectionFilterInfo in
            let subQueryFilters = buildMultiLevelListSelectionFilterInfo(fromQueryFilter: filterQueries.filter)
            let filter = MultiLevelListSelectionFilterInfo(parameterName: queryFilter.parameterName, title: filterQueries.title, isMultiSelect: true, results: filterQueries.totalResults, value: filterQueries.value)
            filter.setSubLevelFilters(subQueryFilters)
            multiLevelFilterLookup[filter.lookupKey] = filter
            selectionDataSource.updateSelectionStateForFilter(filter)
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

            if key == .noOfBedrooms {
                let stepperFilterInfo = buildStepperFilterInfo(from: filterData)
                filterInfo.append(stepperFilterInfo)
            } else if let isRange = filterData.isRange, isRange {
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
