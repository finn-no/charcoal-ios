//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal

enum DemoSections: CaseIterable {
    case components
    case verticals

    var title: String {
        switch self {
        case .components:
            return "Components"
        case .verticals:
            return "Verticals"
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
                Row(title: "Single vertical", filterContainer: .singleVertical),
                Row(title: "Multiple verticals", filterContainer: .multipleVerticals),
            ]
        }
    }
}
