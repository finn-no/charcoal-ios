//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol RangeControl {
    associatedtype RangeValue: Comparable
    var lowValue: RangeValue? { get }
    var highValue: RangeValue? { get }

    func setLowValue(_ value: RangeValue, animated: Bool)
    func setHighValue(_ value: RangeValue, animated: Bool)
}
