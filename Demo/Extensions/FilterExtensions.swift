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

    static func list(name: String, count: Int = 10, isContextFilter: Bool = false) -> Filter {
        Filter(
            kind: .standard,
            title: name,
            key: name,
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
}

// MARK: - Private extensions

private extension Filter {
    static func createListItems(count: Int, parentLevel: String? = nil) -> [Filter] {
        guard count > 0 else { return [] }
        return (1 ... count).map { Self.createListItem(id: $0, parentLevel: parentLevel) }
    }

    static func createListItem(id: Int, parentLevel: String?) -> Filter {
        let itemLevelString: String
        if let parentLevel = parentLevel {
            itemLevelString = "\(parentLevel)_\(id)"
        } else {
            itemLevelString = "\(id)"
        }

        return Filter(
            kind: .standard,
            title: "Sub Item \(itemLevelString)",
            key: "item_\(itemLevelString)",
            value: "\(id)",
            numberOfResults: id,
            subfilters: createListItems(count: id - 1, parentLevel: itemLevelString)
        )
    }
}
