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

    enum CodingKeys: String, CodingKey {
        case market, hits, filterTitle = "label", rawFilterKeys = "filters", filterData = "filter-data"
    }

    public init(from data: Data) throws {
        self = try JSONDecoder().decode(FilterSetup.self, from: data)
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

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            title = try container.decode(String.self, forKey: CodingKeys.title)
            parameterName = try container.decode(String.self, forKey: CodingKeys.name)
            isRange = try container.decodeIfPresent(Bool.self, forKey: CodingKeys.isRange) ?? false
            queries = try container.decodeIfPresent([Query].self, forKey: CodingKeys.queries)
        }

        enum CodingKeys: String, CodingKey {
            case title, isRange = "range", queries, name
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
    }
}
