//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit
import Foundation

final class FilterInfoBuilder {
    let filterData: FilterData

    init(filterData: FilterData) {
        self.filterData = filterData
    }

    func build() -> [FilterInfoType] {
        var info = [FilterInfoType]()

        if filterData.rawFilterKeys.contains(FilterKey.query.rawValue) {
            info.append(buildFreeSearchComponent())
        }

        if let preferenceInfo = buildPreferenceFilterInfo(from: filterData) {
            info.append(preferenceInfo)
        }

        let multiLevelPreferenceInfo = buildMultiLevelFilterInfo(from: filterData)
        multiLevelPreferenceInfo.forEach { info.append($0) }

        return info
    }
}

private extension FilterInfoBuilder {
    func buildFreeSearchComponent() -> FilterInfoType {
        return FreeSearchFilterInfo(currentSearchQuery: nil, searchQueryPlaceholder: "Ord i annonsen", name: "freesearch")
    }

    func buildPreferenceFilterInfo(from filterData: FilterData) -> PreferenceFilterInfo? {
        let filterKeys = FilterKey.preferenceFilterKeys
        let filters = filterKeys.compactMap { filterData.filter(forKey: $0) }

        let preferences = filters.compactMap { filter -> PreferenceInfoType? in
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

    func buildMultiLevelFilterInfo(from filterData: FilterData) -> [MultilevelFilterInfo] {
        let allFilterKeysSet = Set(filterData.filters.map({ $0.key }))
        let preferenceFilterKeys = FilterKey.preferenceFilterKeys
        let rangeFilterKeys = filterData.filters.filter({ $0.isRange }).map { $0.key }

        let multiLevelFilterKeys = allFilterKeysSet.subtracting(preferenceFilterKeys).subtracting(rangeFilterKeys)
        let filters = multiLevelFilterKeys.compactMap { filterData.filter(forKey: $0) }

        let multilevelFilterInfoObjects = filters.compactMap { filter -> MultilevelFilterInfo? in
            if filter.isRange {
                return nil
            }

            let filters = filter.queries?.map({ query -> MultilevelFilterInfo in
                let filters = query.filter?.queries.map { filterQueries -> MultilevelFilterInfo in
                    return MultilevelFilterInfo(filters: [], name: filterQueries.title, results: filterQueries.totalResults)
                }

                return MultilevelFilterInfo(filters: filters ?? [], name: query.title, results: query.totalResults)
            })

            return MultilevelFilterInfo(filters: filters ?? [], name: filter.title, results: 0)
        }

        return multilevelFilterInfoObjects
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
