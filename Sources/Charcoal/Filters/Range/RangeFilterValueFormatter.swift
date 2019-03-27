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
        if isValueCurrency {
            let value = NSNumber(value: value)
            return NumberFormatter.currencyFormatter.string(from: value)
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

// MARK: - Private extensions

extension NumberFormatter {
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        formatter.locale = Locale(identifier: "nb_NO")
        formatter.maximumFractionDigits = 0
        return formatter
    }()
}
