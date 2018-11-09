//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol StepperFilterInfoType: FilterInfoType {
    var unit: String { get }
    var steps: Int { get }
    var lowerLimit: Int { get }
    var upperLimit: Int { get }
}
