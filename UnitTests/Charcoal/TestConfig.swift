import Foundation
import Charcoal
import MapKit

struct TestConfig: CharcoalConfig {
    let currencyConfig: CharcoalCurrencyConfig
    let mapConfig: CharcoalMapConfig

    init(
        localCurrencyLocalized: String = "kr",
        localCurrencyAccessibleLocalized: String = "kroner",
        defaultMapCenterCoordinate: CLLocationCoordinate2D = .oslo
    ) {
        currencyConfig = CurrencyConfig(
            localCurrencyLocalized: localCurrencyLocalized,
            localCurrencyAccessibleLocalized: localCurrencyAccessibleLocalized
        )
        mapConfig = MapConfig(
            defaultMapCenterCoordinate: defaultMapCenterCoordinate
        )
    }
}

private struct CurrencyConfig: CharcoalCurrencyConfig {
    let localCurrencyLocalized: String
    let localCurrencyAccessibleLocalized: String
}

private struct MapConfig: CharcoalMapConfig {
    let defaultMapCenterCoordinate: CLLocationCoordinate2D
}

private extension CLLocationCoordinate2D {
    static let oslo = CLLocationCoordinate2D(latitude: 59.9171, longitude: 10.7275)
}
