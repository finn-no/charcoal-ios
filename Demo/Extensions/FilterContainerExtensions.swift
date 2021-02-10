import Charcoal

extension FilterContainer {
    static var singleVertical: FilterContainer {
        create(rootFilters: [.createList(name: "Kategorier")], numberOfVerticals: 0)
    }

    static var multipleVerticals: FilterContainer {
        create(rootFilters: [.createList(name: "Kategorier")])
    }

    static func create(
        rootFilters: [Filter] = [],
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
}
