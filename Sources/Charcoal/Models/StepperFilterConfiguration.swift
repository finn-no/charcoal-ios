//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public struct StepperFilterConfiguration: Equatable {
    public let minimumValue: Int
    public let maximumValue: Int
    public let unit: String

    public init(minimumValue: Int, maximumValue: Int, unit: String) {
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.unit = unit
    }
}
