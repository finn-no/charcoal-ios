//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal

extension Filter {
    static var freeText: Filter {
        Filter(kind: .freeText, title: "Fritekst", key: "query", value: nil, numberOfResults: 0)
    }

    static func inline(subfilters: [Filter]) -> Filter {
        inline(title: "", key: "inline", subfilters: subfilters)
    }

    static func list(name: String, key: String? = nil, count: Int = 10, isContextFilter: Bool = false) -> Filter {
        Filter(
            kind: .standard,
            title: name,
            key: key ?? name,
            value: nil,
            numberOfResults: 0,
            style: isContextFilter ? .context : .normal,
            subfilters: createListItems(count: count)
        )
    }

    static func price(isContextFilter: Bool = false) -> Filter {
        range(title: "Pris", config: .priceConfiguration, isContextFilter: isContextFilter)
    }

    static func range(title: String, config: RangeFilterConfiguration, isContextFilter: Bool = false) -> Filter {
        range(
            title: title,
            key: title,
            lowValueKey: "\(title)_from",
            highValueKey: "\(title)_to",
            config: .priceConfiguration,
            style: isContextFilter ? .context : .normal
        )
    }

    static func map(includePolygonSearch: Bool = true) -> Filter {
        let filter = map(
            title: "Område i kart",
            key: "map",
            latitudeKey: "lat",
            longitudeKey: "lon",
            radiusKey: "radius",
            locationKey: "locations",
            bboxKey: includePolygonSearch ? "bbox" : nil,
            polygonKey: includePolygonSearch ? "polygon" : nil
        )
        filter.mutuallyExclusiveFilterKeys = ["location"]
        return filter
    }

    static func location() -> Filter {
        let filter = Filter.list(name: "Område", key: "location")
        filter.mutuallyExclusiveFilterKeys = ["map"]
        return filter
    }
}

// MARK: - Private extensions

private extension Filter {
    static func createListItems(count: Int, parentLevel: String? = nil, lastItemIsExternal: Bool = true) -> [Filter] {
        guard count > 0 else { return [] }
        return (1 ... count).map {
            let isExternal = lastItemIsExternal && $0 > 1 && $0 == count
            return Self.createListItem(id: $0, parentLevel: parentLevel, isExternal: isExternal)
        }
    }

    static func createListItem(id: Int, parentLevel: String?, isExternal: Bool) -> Filter {
        let itemLevelString: String
        if let parentLevel = parentLevel {
            itemLevelString = "\(parentLevel)_\(id)"
        } else {
            itemLevelString = "\(id)"
        }

        return Filter(
            kind: isExternal ? .external : .standard,
            title: "Sub Item \(itemLevelString)",
            key: "item_\(itemLevelString)",
            value: "\(id)",
            numberOfResults: id,
            subfilters: createListItems(count: id - 1, parentLevel: itemLevelString)
        )
    }
}
