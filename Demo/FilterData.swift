//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

enum FilterKey: String, CodingKey {
    case query = "q"
    case published
    case location
    case segment
    case searchType = "search_type"
    case condition
    case category
    case price
    // car-norway
    case markets
    case make
    case dealerSegment = "dealer_segment"
    case salesForm = "sales_form"
    case year
    case mileage
    case priceChanged = "price_changed"
    case bodyType = "body_type"
    case engineFuel = "engine_fuel"
    case exteriorColour = "exterior_colour"
    case engineEffect = "engine_effect"
    case numberOfSeats = "number_of_seats"
    case wheelDrive = "wheel_drive"
    case transmission
    case carEquipment = "car_equipment"
    case wheelSets = "wheel_sets"
    case warrantyInsurance = "warranty_insurance"
    case registrationClass = "registration_class"

    static var preferenceFilterKeys: [FilterKey] {
        return [.searchType, .segment, .condition, .published, .priceChanged]
    }
}

struct FilterData: Decodable {
    let market: String
    let hits: Int
    let filterTitle: String
    let rawFilterKeys: [String]
    let filters: [Filter]

    enum CodingKeys: String, CodingKey {
        case market, hits, filterTitle = "label", rawFilterKeys = "filters", filterData = "filter-data"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        market = try container.decode(String.self, forKey: .market)
        hits = try container.decode(Int.self, forKey: .hits)
        filterTitle = try container.decode(String.self, forKey: .filterTitle)
        rawFilterKeys = try container.decode([String].self, forKey: .rawFilterKeys)

        let filterDataContainer = try container.nestedContainer(keyedBy: FilterKey.self, forKey: .filterData)
        let elementKeys = rawFilterKeys.compactMap({ FilterKey(stringValue: $0) })
        filters = try elementKeys.compactMap { elementKey -> Filter? in
            guard let partial = try filterDataContainer.decodeIfPresent(Filter.PartialFilterDataElement.self, forKey: elementKey) else {
                return nil
            }

            return Filter(key: elementKey, partial: partial)
        }
    }

    func filter(forKey key: FilterKey) -> Filter? {
        return filter(forKey: key.rawValue)
    }

    func filter(forKey key: String) -> Filter? {
        return filters.first(where: { $0.key.rawValue == key })
    }
}

struct Filter {
    let key: FilterKey
    let title: String
    let isRange: Bool
    let queries: [Filter.Query]?

    init(key: FilterKey, partial: PartialFilterDataElement) {
        self.key = key
        title = partial.title
        isRange = partial.isRange
        queries = partial.queries
    }
}

extension Filter {
    struct PartialFilterDataElement: Decodable {
        let title: String
        let isRange: Bool
        let queries: [Filter.Query]?

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            title = try container.decode(String.self, forKey: CodingKeys.title)
            isRange = try container.decodeIfPresent(Bool.self, forKey: CodingKeys.isRange) ?? false
            queries = try container.decodeIfPresent([Query].self, forKey: CodingKeys.queries)
        }

        enum CodingKeys: String, CodingKey {
            case title, isRange = "range", queries
        }
    }
}

extension Filter {
    struct Query: Decodable {
        let title: String
        let value: String
        let totalResults: Int
        let filter: Query.Filter?

        enum CodingKeys: String, CodingKey {
            case title, value, totalResults = "total-results", filter
        }
    }
}

extension Filter.Query {
    struct Filter: Decodable {
        let title: String
        let queries: [Filter.Query]
    }
}

extension Filter.Query.Filter {
    struct Query: Decodable {
        let title: String
        let value: String
        let totalResults: Int

        enum CodingKeys: String, CodingKey {
            case title, value, totalResults = "total-results"
        }
    }
}
