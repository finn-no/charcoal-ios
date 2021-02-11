//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal

extension FilterContainer {
    static func create(
        rootFilters: [Filter] = defaultRootFilters(),
        freeTextFilter: Filter? = .freeText,
        inlineFilter: Filter? = nil,
        numberOfResults: Int = 123,
        numberOfVerticals: Int = 4,
        lastVerticalIsExternal: Bool = true
    ) -> FilterContainer {
        let container = FilterContainer(rootFilters: rootFilters, freeTextFilter: freeTextFilter, inlineFilter: inlineFilter, numberOfResults: numberOfResults)
        container.verticals = DemoVertical.create(numberOfVerticals, lastVerticalIsExternal: lastVerticalIsExternal)
        return container
    }

    static func defaultRootFilters(isContextFilters: Bool = false, includePolygonSearch: Bool = true) -> [Filter] {
        [
            .list(name: "Kategorier", isContextFilter: isContextFilters),
            .map(includePolygonSearch: includePolygonSearch),
            .location(),
            .price(isContextFilter: isContextFilters),
        ]
    }
}
