//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal

enum DemoSections: CaseIterable {
    case components
    case verticals
    case misc

    var title: String {
        switch self {
        case .components:
            return "Components"
        case .verticals:
            return "Verticals"
        case .misc:
            return "Miscellaneous"
        }
    }

    var rows: [Row] {
        switch self {
        case .components:
            return [
                Row(title: "Inline Filter", type: InlineFilterDemoViewController.self),
                Row(title: "Range Filter", type: RangeFilterDemoViewController.self),
                Row(title: "Stepper Filter", type: StepperFilterDemoViewController.self),
                Row(title: "Område i kart", type: MapFilterDemoViewController.self),
            ]
        case .verticals:
            return [
                Row(title: "Single vertical", filterContainer: .standard, verticals: .single),
                Row(title: "Multiple verticals", filterContainer: .standard, verticals: .multiple),
            ]
        case .misc:
            return [
                Row(title: "Context filters", filterContainer: .contextFilter),
                Row(title: "Polygon search disabled", filterContainer: .polygonSearchDisabled),
            ]
        }
    }
}

extension FilterContainer {
    static var standard: FilterContainer {
        create()
    }

    static var contextFilter: FilterContainer {
        create(rootFilters: FilterContainer.defaultRootFilters(isContextFilters: true))
    }

    static var polygonSearchDisabled: FilterContainer {
        create(rootFilters: FilterContainer.defaultRootFilters(includePolygonSearch: false))
    }
}
