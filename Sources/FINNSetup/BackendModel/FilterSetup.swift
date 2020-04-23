//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public struct FilterSetup: Decodable {
    public let market: String
    public let filterTitle: String
    public let hits: Int
    public let objectCount: Int?

    let filters: [FilterData]

    enum CodingKeys: String, CodingKey, CaseIterable {
        case market
        case hits
        case objectCount
        case filterTitle = "label"
        case filterData = "filter-data"
    }

    // MARK: - Init

    public init(market: String, hits: Int, objectCount: Int?, filterTitle: String, filters: [FilterData]) {
        self.market = market
        self.hits = hits
        self.objectCount = objectCount
        self.filterTitle = filterTitle
        self.filters = filters
    }

    public init(from data: Data) throws {
        self = try JSONDecoder().decode(type(of: self).self, from: data)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        market = try container.decode(String.self, forKey: .market)
        hits = try container.decodeIfPresent(Int.self, forKey: .hits) ?? 0
        objectCount = try container.decodeIfPresent(Int.self, forKey: .objectCount)
        filterTitle = try container.decodeIfPresent(String.self, forKey: .filterTitle) ?? ""

        let filterDataContainer = try container.nestedContainer(keyedBy: FilterKey.self, forKey: .filterData)

        filters = try filterDataContainer.allKeys.compactMap { elementKey -> FilterData? in
            guard let filterData = try filterDataContainer.decodeIfPresent(FilterData.self, forKey: elementKey) else {
                return nil
            }

            return filterData
        }
    }

    // MARK: - Factory

    public func filterContainer(using config: FilterConfiguration, excludedFilters: [FilterKey] = []) -> FilterContainer {
        let rootFilters = config.rootLevelFilterKeys.compactMap { key -> Filter? in
            if excludedFilters.contains(key) {
                return nil
            }
            let filter = makeRootLevelFilter(withKey: key, using: config, excludedFilters: excludedFilters)
            filter?.mutuallyExclusiveFilterKeys = Set(config.mutuallyExclusiveFilters(for: key).map { $0.rawValue })
            return filter
        }

        let preferenceFilters = config.preferenceFilterKeys.compactMap { key -> Filter? in
            if excludedFilters.contains(key) {
                return nil
            }
            return filterData(forKey: key).flatMap { makeFilter(from: $0, withKind: .standard, style: .normal) }
        }

        let container = FilterContainer(
            rootFilters: rootFilters,
            freeTextFilter: Filter.freeText(key: FilterKey.query.rawValue),
            inlineFilter: Filter.inline(title: "", key: FilterKey.preferences.rawValue, subfilters: preferenceFilters),
            numberOfResults: objectCount ?? hits
        )

        return container
    }

    private func makeRootLevelFilter(withKey key: FilterKey, using config: FilterConfiguration, excludedFilters: [FilterKey]) -> Filter? {
        let style: Filter.Style = config.contextFilterKeys.contains(key) ? .context : .normal

        switch key {
        case .map:
            return makeMapFilter(withKey: key, excludePolygonSearch: excludedFilters.contains(.polygon))
        case .shoeSize:
            guard let data = filterData(forKey: key) else { return nil }
            return makeFilter(from: data, withKind: .grid, style: style)
        default:
            guard let data = filterData(forKey: key) else { return nil }

            if data.isRange == true {
                if let filterConfig = config.rangeConfiguration(forKey: key) {
                    return makeRangeFilter(from: data, config: filterConfig, style: style)
                } else if let filterConfig = config.stepperConfiguration(forKey: key) {
                    return makeStepperFilter(from: data, config: filterConfig, style: style)
                } else {
                    return nil
                }
            } else {
                guard !data.queries.isEmpty else {
                    return nil
                }
                return makeFilter(from: data, withKind: .standard, style: style)
            }
        }
    }

    private func makeMapFilter(withKey key: FilterKey, excludePolygonSearch: Bool) -> Filter {
        return Filter.map(
            key: key.rawValue,
            latitudeKey: FilterKey.latitude.rawValue,
            longitudeKey: FilterKey.longitude.rawValue,
            radiusKey: FilterKey.radius.rawValue,
            locationKey: FilterKey.geoLocationName.rawValue,
            bboxKey: excludePolygonSearch ? nil : FilterKey.bbox.rawValue,
            polygonKey: excludePolygonSearch ? nil : FilterKey.polygon.rawValue
        )
    }

    private func makeStepperFilter(from filterData: FilterData, config: StepperFilterConfiguration, style: Filter.Style) -> Filter {
        return Filter.stepper(title: filterData.title, key: filterData.parameterName + "_from", config: config, style: style)
    }

    private func makeRangeFilter(from filterData: FilterData, config: RangeFilterConfiguration, style: Filter.Style) -> Filter {
        let key = filterData.parameterName

        return Filter.range(
            title: filterData.title,
            key: key,
            lowValueKey: key + "_from",
            highValueKey: key + "_to",
            config: config,
            style: style
        )
    }

    private func makeFilter(from filterData: FilterData, withKind kind: Filter.Kind, style: Filter.Style) -> Filter? {
        let subfilters = filterData.queries.compactMap {
            makeListFilter(withKey: filterData.parameterName, from: $0)
        }

        if style == .context, subfilters.count < 2 {
            return nil
        } else {
            return Filter(
                kind: kind,
                title: filterData.title,
                key: filterData.parameterName,
                style: style,
                subfilters: subfilters
            )
        }
    }

    private func makeListFilter(withKey key: String, from query: FilterDataQuery) -> Filter {
        let filter = query.filter
        let subfilters = filter?.queries.compactMap {
            makeListFilter(withKey: filter?.parameterName ?? "", from: $0)
        }

        if ["2.69.3964.268", "1.69.3965"].contains(query.value) {
            return Filter.external(title: query.title, key: key, value: query.value, numberOfResults: query.totalResults)
        } else {
            return Filter(
                title: query.title,
                key: key,
                value: query.value,
                numberOfResults: query.totalResults,
                subfilters: subfilters ?? []
            )
        }
    }

    public static func decode(from dict: [AnyHashable: Any]?) -> FilterSetup? {
        guard let dict = dict else {
            return nil
        }

        guard let market = dict[CodingKeys.market.rawValue] as? String else {
            return nil
        }

        guard let filterDataDict = dict[CodingKeys.filterData.rawValue] as? [AnyHashable: Any] else {
            return nil
        }

        let filters = filterDataDict.compactMap { (key, value) -> FilterData? in
            guard let key = key as? String, let elementKey = FilterKey(stringValue: key) else {
                return nil
            }
            guard let filterData = FilterData.decode(from: value as? [AnyHashable: Any]) else {
                return nil
            }
            if elementKey.rawValue != filterData.parameterName {
                print("help")
            }
            return filterData
        }

        let hits = (dict[CodingKeys.hits.rawValue] as? Int) ?? 0
        let filterTitle = (dict[CodingKeys.filterTitle.rawValue] as? String) ?? ""
        let objectCount = dict[CodingKeys.objectCount.rawValue] as? Int

        return FilterSetup(
            market: market,
            hits: hits,
            objectCount: objectCount,
            filterTitle: filterTitle,
            filters: filters
        )
    }

    func filterData(forKey key: FilterKey) -> FilterData? {
        return filters.first(where: { $0.parameterName == key.rawValue })
    }
}
