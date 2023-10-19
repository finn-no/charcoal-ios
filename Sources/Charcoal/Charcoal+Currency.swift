import Foundation

extension Charcoal {
    struct CurrencyConfig {
        let localCurrencyLocalized: String
        let localCurrencyAccessibleLocalized: String
    }

    static private(set) var currencyConfig: CurrencyConfig?

    public static func configure(
        localCurrencyLocalized: String,
        localCurrencyAccessibleLocalized: String
    ) {
        self.currencyConfig = .init(
            localCurrencyLocalized: localCurrencyLocalized,
            localCurrencyAccessibleLocalized: localCurrencyAccessibleLocalized
        )
    }
}
