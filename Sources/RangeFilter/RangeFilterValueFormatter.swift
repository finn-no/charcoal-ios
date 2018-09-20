//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public class RangeFilterValueFormatter: NSObject {
    private let isValueCurrency: Bool

    private lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = isValueCurrency ? .currency : .none
        formatter.currencySymbol = ""
        formatter.locale = Locale(identifier: "nb_NO")
        formatter.maximumFractionDigits = 0

        return formatter
    }()

    public init(isValueCurrency: Bool) {
        self.isValueCurrency = isValueCurrency
    }

    public func string(from value: Int, isCurrency: Bool = false) -> String? {
        let value = NSNumber(value: value)
        return formatter.string(from: value)
    }
}
