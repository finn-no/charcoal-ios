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
            guard let partial = try filterDataContainer.decodeIfPresent(FilterData.PartialFilterDataElement.self, forKey: elementKey) else {
                return nil
            }

            return FilterData(key: elementKey, partial: partial)
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
            guard let partial = FilterData.PartialFilterDataElement.decode(from: filterDataDict[elementKey.stringValue] as? [AnyHashable: Any]) else {
                return nil
            }
            return FilterData(key: elementKey, partial: partial)
        }

        return FilterSetup(market: market, hits: hits, filterTitle: filterTitle, rawFilterKeys: rawFilterKeys, filters: filters)
    }

    func filterData(forKey key: FilterKey) -> FilterData? {
        return filters.first(where: { $0.key == key })
    }
}

struct FilterData {
    let key: FilterKey
    let title: String
    let parameterName: String
    let isRange: Bool
    let queries: [FilterData.Query]?

    init(key: FilterKey, partial: PartialFilterDataElement) {
        self.key = key
        title = partial.title
        parameterName = partial.parameterName
        isRange = partial.isRange
        queries = partial.queries
    }
}

extension FilterData {
    struct PartialFilterDataElement: Decodable {
        let title: String
        let parameterName: String
        let isRange: Bool
        let queries: [FilterData.Query]?

        private init(title: String, parameterName: String, isRange: Bool, queries: [FilterData.Query]?) {
            self.title = title
            self.parameterName = parameterName
            self.isRange = isRange
            self.queries = queries
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            title = try container.decode(String.self, forKey: CodingKeys.title)
            parameterName = try container.decode(String.self, forKey: CodingKeys.parameterName)
            isRange = try container.decodeIfPresent(Bool.self, forKey: CodingKeys.isRange) ?? false
            queries = try container.decodeIfPresent([Query].self, forKey: CodingKeys.queries)
        }

        enum CodingKeys: String, CodingKey {
            case title, isRange = "range", queries, parameterName = "name"
        }

        static func decode(from dict: [AnyHashable: Any]?) -> PartialFilterDataElement? {
            guard let dict = dict else {
                return nil
            }
            let title = dict[CodingKeys.title.rawValue] as? String
            let parameterName = dict[CodingKeys.parameterName.rawValue] as? String
            let isRange = dict[CodingKeys.isRange.rawValue] as? Bool ?? false
            let queriesArray = dict[CodingKeys.queries.rawValue] as? [[AnyHashable: Any]]
            let queries = FilterData.Query.decode(from: queriesArray)

            if let title = title, let parameterName = parameterName {
                return PartialFilterDataElement(title: title, parameterName: parameterName, isRange: isRange, queries: queries)
            }
            return nil
        }
    }
}

extension FilterData {
    struct Query: Decodable {
        let title: String
        let value: String
        let totalResults: Int
        let filter: QueryFilter?

        enum CodingKeys: String, CodingKey {
            case title, value, totalResults = "total-results", filter
        }

        static func decode(from dict: [AnyHashable: Any]?) -> Query? {
            guard let dict = dict else {
                return nil
            }
            let title = dict[CodingKeys.title.rawValue] as? String
            let value = dict[CodingKeys.value.rawValue] as? String
            let totalResults = dict[CodingKeys.totalResults.rawValue] as? Int
            let filter = QueryFilter.decode(from: dict[CodingKeys.filter.rawValue] as? [AnyHashable: Any])

            if let title = title, let value = value {
                return Query(title: title, value: value, totalResults: totalResults ?? 0, filter: filter)
            }
            return nil
        }

        static func decode(from array: [[AnyHashable: Any]]?) -> [Query]? {
            guard let array = array else {
                return nil
            }
            return array.compactMap { (dict) -> Query? in
                return Query.decode(from: dict)
            }
        }
    }
}

extension FilterData.Query {
    struct QueryFilter: Decodable {
        let title: String
        let parameterName: String
        let queries: [FilterData.Query]

        enum CodingKeys: String, CodingKey {
            case title, parameterName = "name", queries
        }

        static func decode(from dict: [AnyHashable: Any]?) -> QueryFilter? {
            guard let dict = dict else {
                return nil
            }
            let title = dict[CodingKeys.title.rawValue] as? String
            let parameterName = dict[CodingKeys.parameterName.rawValue] as? String
            let queriesArray = dict[CodingKeys.queries.rawValue] as? [[AnyHashable: Any]]
            let queries = FilterData.Query.decode(from: queriesArray)

            if let title = title, let parameterName = parameterName {
                return QueryFilter(title: title, parameterName: parameterName, queries: queries ?? [])
            }
            return nil
        }
    }
}
