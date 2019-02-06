//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

class CCRangeSelectionTiltesBuilder: CCSelectionTitlesBuilder {
    func build(_ selectedNodes: [CCFilterNode]) -> [String] {
        let lowValue = selectedNodes[0].value
        let highValue = selectedNodes[1].value
        if let lowValue = lowValue, let highValue = highValue {
            return ["\(lowValue) - \(highValue)"]
        } else if let lowValue = lowValue {
            return ["\(lowValue) - ..."]
        } else if let highValue = highValue {
            return ["... - \(highValue)"]
        } else {
            return []
        }
    }
}
