//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class MapDistanceValueFormatter: SliderValueFormatter {
    func accessibilityValue(for value: Int) -> String {
        return title(for: value)
    }

    func title(for value: Int) -> String {
        let useKm = value > 1500

        if useKm {
            let km = value / 1000
            return "\(km) km"
        } else {
            return "\(value) m"
        }
    }

    private func supportedValueToInt<ValueKind>(_ value: ValueKind) -> Int? {
        if let value = value as? Int {
            return value
        }
        if let value = value as? Float {
            return Int(value)
        }
        if let value = value as? CGFloat {
            return Int(value)
        }
        if let value = value as? Double {
            return Int(value)
        }
        return nil
    }
}
