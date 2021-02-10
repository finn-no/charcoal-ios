import Charcoal

extension Filter {
    static var freeText: Filter {
        Filter(kind: .freeText, title: "Fritekst", key: "query", value: nil, numberOfResults: 0)
    }

    static func inline(subfilters: [Filter]) -> Filter {
        inline(title: "", key: "inline", subfilters: subfilters)
    }

    static func createList(name: String, style: Filter.Style = .normal, count: Int = 10) -> Filter {
        Filter(
            kind: .standard,
            title: name,
            key: name,
            value: nil,
            numberOfResults: 0,
            style: style,
            subfilters: createListItems(count: count)
        )
    }

    private static func createListItems(count: Int, parentLevel: String? = nil) -> [Filter] {
        guard count > 0 else { return [] }
        return (1 ... count).map { Self.createListItem(id: $0, parentLevel: parentLevel) }
    }

    private static func createListItem(id: Int, parentLevel: String?) -> Filter {
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
