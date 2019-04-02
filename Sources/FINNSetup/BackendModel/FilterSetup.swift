//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public struct FilterSetup: Decodable {
    public let market: String
    public let filterTitle: String
    public let hits: Int
    public let objectCount: Int?

    let rawFilterKeys: [String]
    let filters: [FilterData]

    enum CodingKeys: String, CodingKey, CaseIterable {
        case market
        case hits
        case objectCount
        case filterTitle = "label"
        case rawFilterKeys = "filters"
        case filterData = "filter-data"
    }

    // MARK: - Init

    private init(market: String, hits: Int, objectCount: Int?, filterTitle: String, rawFilterKeys: [String], filters: [FilterData]) {
        self.market = market
        self.hits = hits
        self.objectCount = objectCount
        self.filterTitle = filterTitle
        self.rawFilterKeys = rawFilterKeys
        self.filters = filters
    }

    public init(from data: Data) throws {
        self = try JSONDecoder().decode(type(of: self).self, from: data)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        market = try container.decode(String.self, forKey: .market)
        hits = try container.decode(Int.self, forKey: .hits)
        objectCount = try container.decodeIfPresent(Int.self, forKey: .objectCount)
        filterTitle = try container.decode(String.self, forKey: .filterTitle)
        rawFilterKeys = try container.decode([String].self, forKey: .rawFilterKeys)

        let filterDataContainer = try container.nestedContainer(keyedBy: FilterKey.self, forKey: .filterData)
        let elementKeys = rawFilterKeys.compactMap({ FilterKey(stringValue: $0) })

        filters = try elementKeys.compactMap { elementKey -> FilterData? in
            guard let filterData = try filterDataContainer.decodeIfPresent(FilterData.self, forKey: elementKey) else {
                return nil
            }

            return filterData
        }
    }

    // MARK: - Factory

    public func filterContainer(using config: FilterConfiguration) -> FilterContainer {
        let rootLevelFilters = config.rootLevelFilters.compactMap { key -> Filter? in
            let filter = makeRootLevelFilter(withKey: key, using: config)
            filter?.mutuallyExclusiveFilterKeys = config.mutuallyExclusiveFilters(for: key)
            return filter
        }

        // TODO: move to Localizable.strings when we create this file for priming
        let title = "Filtrer søket"
        let numberOfResults = objectCount ?? hits
        let root = Filter.list(title: title, key: market, numberOfResults: numberOfResults, subfilters: rootLevelFilters)

        return FilterContainer(root: root)
    }

    private func makeRootLevelFilter(withKey key: String, using config: FilterConfiguration) -> Filter? {
        switch key {
        case FilterKey.query.rawValue:
            return Filter.search(key: key)
        case FilterKey.preferences.rawValue:
            let subfilters = config.preferenceFilters.compactMap {
                filterData(forKey: $0).flatMap({ makeListFilter(from: $0, withStyle: .normal) })
            }
            return Filter.inline(title: "", key: key, subfilters: subfilters)
        case FilterKey.map.rawValue:
            return makeMapFilter(withKey: key)
        default:
            guard let data = filterData(forKey: key) else { return nil }

            let style: Filter.Style = config.contextFilters.contains(key) ? .context : .normal

            if data.isRange == true {
                if let filterConfig = config.rangeConfiguration(forKey: key) {
                    return makeRangeFilter(from: data, config: filterConfig, style: style)
                } else if let filterConfig = config.stepperConfiguration(forKey: key) {
                    return makeStepperFilter(from: data, config: filterConfig, style: style)
                } else {
                    return nil
                }
            } else {
                return makeListFilter(from: data, withStyle: style)
            }
        }
    }

    private func makeMapFilter(withKey key: String) -> Filter {
        return Filter.map(
            key: key,
            latitudeKey: FilterKey.latitude.rawValue,
            longitudeKey: FilterKey.longitude.rawValue,
            radiusKey: FilterKey.radius.rawValue,
            locationKey: FilterKey.geoLocationName.rawValue
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

    private func makeListFilter(from filterData: FilterData, withStyle style: Filter.Style) -> Filter? {
        let subfilters = filterData.queries.compactMap({
            makeListFilter(withKey: filterData.parameterName, from: $0)
        })

        if style == .context && subfilters.count < 2 {
            return nil
        } else {
            return Filter.list(
                title: filterData.title,
                key: filterData.parameterName,
                style: style,
                subfilters: subfilters
            )
        }
    }

    private func makeListFilter(withKey key: String, from query: FilterDataQuery) -> Filter {
        let filter = query.filter
        let subfilters = filter?.queries.compactMap({
            makeListFilter(withKey: filter?.parameterName ?? "", from: $0)
        })

        if ["2.69.3964.268", "1.69.3965"].contains(query.value) {
            return Filter.external(title: query.title, key: key, value: query.value, numberOfResults: query.totalResults)
        } else {
            return Filter.list(
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

        guard let hits = dict[CodingKeys.hits.rawValue] as? Int else {
            return nil
        }

        guard let filterTitle = dict[CodingKeys.filterTitle.rawValue] as? String else {
            return nil
        }

        guard let rawFilterKeys = dict[CodingKeys.rawFilterKeys.rawValue] as? [String] else {
            return nil
        }

        guard let filterDataDict = dict[CodingKeys.filterData.rawValue] as? [AnyHashable: Any] else {
            return nil
        }

        let elementKeys = rawFilterKeys.compactMap({ FilterKey(stringValue: $0) })
        let filters = elementKeys.compactMap { elementKey -> FilterData? in
            guard let filterData = FilterData.decode(from: filterDataDict[elementKey.stringValue] as? [AnyHashable: Any]) else {
                return nil
            }
            if elementKey.rawValue != filterData.parameterName {
                print("help")
            }
            return filterData
        }

        let objectCount = dict[CodingKeys.objectCount.rawValue] as? Int

        return FilterSetup(
            market: market,
            hits: hits,
            objectCount: objectCount,
            filterTitle: filterTitle,
            rawFilterKeys: rawFilterKeys,
            filters: filters
        )
    }

    func filterData(forKey key: String) -> FilterData? {
        return filters.first(where: { $0.parameterName == key })
    }
}
