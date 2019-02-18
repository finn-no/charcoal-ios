//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

struct FilterDataQuery: Decodable {
    let title: String
    let value: String
    let totalResults: Int
    let filter: FilterData?

    enum CodingKeys: String, CodingKey {
        case title, value, totalResults = "total-results", filter
    }

    static func decode(from dict: [AnyHashable: Any]?) -> FilterDataQuery? {
        guard let dict = dict else {
            return nil
        }
        guard let title = dict[CodingKeys.title.rawValue] as? String else {
            return nil
        }
        guard let value = dict[CodingKeys.value.rawValue] as? String else {
            return nil
        }
        let totalResults = dict[CodingKeys.totalResults.rawValue] as? Int
        let filter = FilterData.decode(from: dict[CodingKeys.filter.rawValue] as? [AnyHashable: Any])

        return FilterDataQuery(title: title, value: value, totalResults: totalResults ?? 0, filter: filter)
    }

    func filterNode(name: String) -> CCFilterNode {
        let filterNode = CCFilterNode(title: title, name: name, value: value, numberOfResults: totalResults)
        if let filterData = filter {
            filterData.queries.forEach({ query in
                filterNode.add(child: query.filterNode(name: filterData.parameterName))
            })
        }
        return filterNode
    }

    static func decode(from array: [[AnyHashable: Any]]?) -> [FilterDataQuery]? {
        guard let array = array else {
            return nil
        }
        return array.compactMap { (dict) -> FilterDataQuery? in
            return FilterDataQuery.decode(from: dict)
        }
    }
}
