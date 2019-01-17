//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

class RangeFilterValueFormatter: NSObject, SliderValueFormatter {
    private let isValueCurrency: Bool
    private let unit: String
    private let accessibilityUnit: String

    private lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = isValueCurrency ? .currency : .none
        formatter.currencySymbol = ""
        formatter.locale = Locale(identifier: "nb_NO")
        formatter.maximumFractionDigits = 0

        return formatter
    }()

    init(isValueCurrency: Bool, unit: String, accessibilityUnit: String) {
        self.isValueCurrency = isValueCurrency
        self.unit = unit
        self.accessibilityUnit = accessibilityUnit
    }

    func string(from value: Int, isCurrency: Bool = false) -> String? {
        let value = NSNumber(value: value)
        return formatter.string(from: value)
    }

    func accessibilityValue<ValueKind>(for value: ValueKind) -> String {
        return "\(value) \(accessibilityUnit)"
    }

    func title<ValueKind>(for value: ValueKind) -> String {
        return "\(value) \(unit)"
    }
}
