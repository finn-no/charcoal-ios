//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public struct FilterData: Decodable {
    let title: String
    let parameterName: String
    let queries: [FilterDataQuery]
    let isRange: Bool?

    enum CodingKeys: String, CodingKey {
        case title, parameterName = "name", queries, isRange = "range"
    }

    private init?(title: String, parameterName: String, isRange: Bool?, queries: [FilterDataQuery]?) {
        self.title = title
        self.parameterName = parameterName
        self.isRange = isRange
        self.queries = queries ?? []
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: CodingKeys.title)
        parameterName = try container.decode(String.self, forKey: CodingKeys.parameterName)
        isRange = try container.decodeIfPresent(Bool.self, forKey: CodingKeys.isRange)
        queries = try container.decodeIfPresent([FilterDataQuery].self, forKey: CodingKeys.queries) ?? []
    }

    static func decode(from dict: [AnyHashable: Any]?) -> FilterData? {
        guard let dict = dict else {
            return nil
        }
        guard let title = dict[CodingKeys.title.rawValue] as? String else {
            return nil
        }
        guard let parameterName = dict[CodingKeys.parameterName.rawValue] as? String else {
            return nil
        }
        let queriesArray = dict[CodingKeys.queries.rawValue] as? [[AnyHashable: Any]]
        let queries = FilterDataQuery.decode(from: queriesArray)

        let isRange = dict[CodingKeys.isRange.rawValue] as? Bool

        return FilterData(title: title, parameterName: parameterName, isRange: isRange, queries: queries ?? [])
    }
}
