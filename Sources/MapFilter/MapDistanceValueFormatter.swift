//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

class MapDistanceValueFormatter: SliderValueFormatter {
    func title<ValueKind>(for value: ValueKind) -> String {
        guard let value = supportedValueToInt(value) else {
            return ""
        }
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
