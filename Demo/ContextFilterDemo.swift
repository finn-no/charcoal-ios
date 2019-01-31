//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal

class ContextFilterDemo {
    weak var rootStateController: FilterRootStateController?
    let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource()

    private var loadedFilter: FilterInfoBuilderResult
    private var filterSetup: FilterSetup

    init(filename: String) {
        filterSetup = DemoFilter.filterDataFromJSONFile(named: filename)
        let filterInfoBuilder = FilterInfoBuilder(filter: filterSetup, selectionDataSource: ParameterBasedFilterInfoSelectionDataSource())
        loadedFilter = filterInfoBuilder.build()!
        selectionDataSource.delegate = self
    }
}

extension ContextFilterDemo: ParameterBasedFilterInfoSelectionDataSourceDelegate {
    func parameterBasedFilterInfoSelectionDataSourceDidChange(_: ParameterBasedFilterInfoSelectionDataSource) {
        filterSetup = DemoFilter.filterDataFromJSONFile(named: "data-with-context")
        let filterInfoBuilder = FilterInfoBuilder(filter: filterSetup, selectionDataSource: selectionDataSource)
        loadedFilter = filterInfoBuilder.build()!
        rootStateController?.change(to: .filtersUpdated(data: self))
    }
}

extension ContextFilterDemo: FilterDataSource {
    var searchQuery: SearchQueryFilterInfoType? {
        return loadedFilter.searchQuery
    }

    var verticals: [Vertical] {
        return []
    }

    var preferences: [PreferenceFilterInfoType] {
        return loadedFilter.preferences
    }

    var filters: [FilterInfoType] {
        return loadedFilter.filters
    }

    var numberOfHits: Int {
        return filterSetup.hits
    }

    var filterTitle: String {
        return filterSetup.filterTitle
    }

    func numberOfHits(for filterValue: FilterValueType) -> Int {
        return loadedFilter.filterValueLookup[filterValue.lookupKey]?.results ?? 0
    }
}
