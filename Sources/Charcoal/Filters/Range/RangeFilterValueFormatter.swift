//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

final class RangeFilterValueFormatter: SliderValueFormatter {
    private let unit: FilterUnit

    // MARK: - Init

    init(unit: FilterUnit) {
        self.unit = unit
    }

    // MARK: - Formatter

    func string(from value: Int) -> String? {
        if unit.shouldFormatWithSeparator {
            return value.decimalFormatted
        } else {
            return "\(value)"
        }
    }

    func accessibilityValue(for value: Int) -> String {
        return "\(value) \(unit.accessibilityValue)"
    }

    func title(for value: Int) -> String {
        return "\(value) \(unit.value)"
    }
}
