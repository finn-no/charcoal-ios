//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public enum RangeValue {
    case minimum(lowValue: Int)
    case maximum(highValue: Int)
    case closed(lowValue: Int, highValue: Int)
}
