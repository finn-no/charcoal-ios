//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal

extension FilterContainer {
    static func create(
        rootFilters: [Filter] = defaultRootFilters(),
        freeTextFilter: Filter? = .freeText,
        inlineFilter: Filter? = defaultInlineFilter(),
        numberOfResults: Int = 123
    ) -> FilterContainer {
        FilterContainer(rootFilters: rootFilters, freeTextFilter: freeTextFilter, inlineFilter: inlineFilter, numberOfResults: numberOfResults)
    }

    static func defaultRootFilters(isContextFilters: Bool = false, includePolygonSearch: Bool = true) -> [Filter] {
        [
            .list(name: "Kategori", isContextFilter: isContextFilters),
            .map(includePolygonSearch: includePolygonSearch),
            .location(),
            .price(isContextFilter: isContextFilters),
        ]
    }

    static func defaultInlineFilter() -> Filter {
        .inline(subfilters: [
            Filter(title: "", key: "inline-1", subfilters: [
                Filter(title: "Til salgs", key: "1"),
                Filter(title: "Gis bort", key: "2"),
                Filter(title: "Ønskes kjøpt", key: "3"),
            ]),
            Filter(title: "", key: "inline-2", subfilters: [
                Filter(title: "Forhandler", key: "1"),
                Filter(title: "Privat", key: "2"),
            ]),
            Filter(title: "", key: "inline-3", subfilters: [
                Filter(title: "Brukt", key: "1"),
                Filter(title: "Nytt", key: "2"),
            ]),
            Filter(title: "", key: "inline-4", subfilters: [
                Filter(title: "Nye i dag", key: "1"),
            ]),
        ])
    }
}
