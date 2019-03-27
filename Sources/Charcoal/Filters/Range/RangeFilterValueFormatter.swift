//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

final class RangeFilterValueFormatter: NSObject, SliderValueFormatter {
    private let isValueCurrency: Bool
    private let unit: String
    private let accessibilityUnit: String

    init(isValueCurrency: Bool, unit: String, accessibilityUnit: String) {
        self.isValueCurrency = isValueCurrency
        self.unit = unit
        self.accessibilityUnit = accessibilityUnit
    }

    func string(from value: Int) -> String? {
        let value = NSNumber(value: value)
        let formatter: NumberFormatter = isValueCurrency ? .currencyFormatter : .standardFormatter
        return formatter.string(from: value)
    }

    func accessibilityValue<ValueKind>(for value: ValueKind) -> String {
        return "\(value) \(accessibilityUnit)"
    }

    func title<ValueKind>(for value: ValueKind) -> String {
        return "\(value) \(unit)"
    }
}

// MARK: - Private extensions

extension NumberFormatter {
    static let standardFormatter = NumberFormatter(isValueCurrency: true)
    static let currencyFormatter = NumberFormatter(isValueCurrency: true)

    private convenience init(isValueCurrency: Bool) {
        self.init()
        numberStyle = isValueCurrency ? .currency : .none
        currencySymbol = ""
        locale = Locale(identifier: "nb_NO")
        maximumFractionDigits = 0
    }
}
