//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

enum DemoSections: CaseIterable {
    case components

    var title: String {
        switch self {
        case .components:
            return "Components"
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
        }
    }
}
