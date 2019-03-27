//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

final class RangeFilterValueFormatter: NSObject, SliderValueFormatter {
    private let formatWithSeparator: Bool
    private let unit: String
    private let accessibilityUnit: String

    // MARK: - Init

    init(formatWithSeparator: Bool, unit: String, accessibilityUnit: String) {
        self.formatWithSeparator = formatWithSeparator
        self.unit = unit
        self.accessibilityUnit = accessibilityUnit
    }

    // MARK: - Formatter

    func string(from value: Int) -> String? {
        if formatWithSeparator {
            return NumberFormatter.decimalFormatter.string(from: value)
        } else {
            return "\(value)"
        }
    }

    func accessibilityValue<ValueKind>(for value: ValueKind) -> String {
        return "\(value) \(accessibilityUnit)"
    }

    func title<ValueKind>(for value: ValueKind) -> String {
        return "\(value) \(unit)"
    }
}
