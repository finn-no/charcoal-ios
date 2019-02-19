//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public struct FilterSetup: Decodable {
    public let market: String
    public let hits: Int
    public let filterTitle: String
    let rawFilterKeys: [String]
    let filters: [FilterData]

    enum CodingKeys: String, CodingKey, CaseIterable {
        case market, hits, filterTitle = "label", rawFilterKeys = "filters", filterData = "filter-data"
    }

    private init(market: String, hits: Int, filterTitle: String, rawFilterKeys: [String], filters: [FilterData]) {
        self.market = market
        self.hits = hits
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

    public func asCCFilter() -> FilterContainer? {
        guard let filterMarket = FilterMarket(market: market) else {
            return nil
        }

        let searchQueryFilter = Filter(title: "search_placeholder".localized(), name: "q")

        let preferenceFilters = filterMarket.preferenceFilterKeys.compactMap { filterData(forKey: $0) }
        let preferenceFilter = Filter(title: "", name: "preferences")
        preferenceFilters.forEach { preferenceFilter.add(subfilter: $0.asFilter()) }

        let filters = filterMarket.supportedFiltersKeys.compactMap { key -> Filter? in
            let kind: Filter.Kind = filterMarket.contextFilters.contains(key) ? .context : .normal
            return filterData(forKey: key)?.asFilter(of: kind)
        }

        if let locationFilter = filters.first(where: { $0.name == filterMarket.filterKeyWithMapSubfilter?.rawValue }) {
            let mapFilter = MapFilter(
                title: "map_filter_title".localized(),
                name: "map",
                latitudeName: "lat",
                longitudeName: "lon",
                radiusName: "radius",
                locationName: "geoLocationName"
            )
            locationFilter.add(subfilter: mapFilter, at: 0)
        }

        let root = Filter(title: filterTitle, name: market, numberOfResults: hits)
        ([searchQueryFilter, preferenceFilter] + filters).forEach { root.add(subfilter: $0) }

        return FilterContainer(root: root)
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

        return FilterSetup(market: market, hits: hits, filterTitle: filterTitle, rawFilterKeys: rawFilterKeys, filters: filters)
    }

    func filterData(forKey key: FilterKey) -> FilterData? {
        return filters.first(where: { $0.parameterName == key.rawValue })
    }
}
