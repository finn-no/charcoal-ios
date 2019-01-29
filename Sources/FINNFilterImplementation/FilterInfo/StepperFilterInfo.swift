//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class StepperFilterInfo: StepperFilterInfoType, ParameterBasedFilterInfo {
    public let unit: String
    public let steps: Int
    public let lowerLimit: Int
    public let upperLimit: Int
    public let title: String
    public let parameterName: String
    public var isContextFilter: Bool = false

    public init(unit: String, steps: Int, lowerLimit: Int, upperLimit: Int, title: String, parameterName: String) {
        self.unit = unit
        self.steps = steps
        self.lowerLimit = lowerLimit
        self.upperLimit = upperLimit
        self.title = title
        self.parameterName = parameterName
    }
}
