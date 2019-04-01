//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

extension RangeFilterConfiguration {
    static func makeStub() -> RangeFilterConfiguration {
        return RangeFilterConfiguration(
            minimumValue: 0,
            maximumValue: 10,
            valueKind: .incremented(10),
            hasLowerBoundOffset: false,
            hasUpperBoundOffset: false,
            unit: .currency,
            usesSmallNumberInputFont: false
        )
    }
}
