//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public enum FilterSelectionValue {
    case singleSelection(value: String)
    case mulitpleSelection(values: [String])
    case rangeSelection(lowValue: Int?, highValue: Int?)
}
