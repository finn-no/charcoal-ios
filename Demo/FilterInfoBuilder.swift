//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit
import Foundation

final class FilterInfoBuilder {
    let filter: Filter

    init(filter: Filter) {
        self.filter = filter
    }

    func build() -> [FilterInfoType] {
        var info = [FilterInfoType]()
        var buildKeys = filter.rawFilterKeys.compactMap { FilterKey(rawValue: $0) }

        if let queryIndex = buildKeys.index(of: FilterKey.query) {
            buildKeys.remove(at: queryIndex)
            info.append(buildFreeSearchFilterInfo())
        }

        let preferenceInfoKeys = buildKeys.filter({ FilterKey.preferenceFilterKeys.contains($0) })
        preferenceInfoKeys.forEach { key in
            if let index = buildKeys.index(of: key) {
                buildKeys.remove(at: index)
            }
        }

        if let preferenceFilterInfo = buildPreferenceFilterInfo(fromKeys: preferenceInfoKeys) {
            info.append(preferenceFilterInfo)
        }

        let remainingFilters = buildFilterInfo(fromKeys: buildKeys)
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

struct FilterInfo: FilterInfoType {
    let name: String
}

struct FreeSearchFilterInfo: FreeSearchFilterInfoType {
    var currentSearchQuery: String?
    var searchQueryPlaceholder: String
    var name: String
}

struct PreferenceFilterInfo: PreferenceFilterInfoType {
    var preferences: [PreferenceInfoType]
    var name: String
}

struct PreferenceInfo: PreferenceInfoType {
    let name: String
    let values: [PreferenceValueType]
    let isMultiSelect: Bool = true
}

struct PreferenceValue: PreferenceValueType {
    let name: String
    var results: Int
}

struct MultilevelFilterInfo: MultiLevelFilterInfoType {
    var filters: [MultiLevelFilterInfoType]
    var name: String
    let isMultiSelect: Bool = true
    let results: Int
}

struct RangeFilterInfo: RangeFilterInfoType {
    var name: String
    var lowValue: Int
    var highValue: Int
    var steps: Int
    var unit: String
}
