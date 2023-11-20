import Foundation
import Charcoal
import MapKit

struct DemoConfig: CharcoalConfig {
    let currencyConfig: CharcoalCurrencyConfig = DemoCurrencyConfig()
    let mapConfig: CharcoalMapConfig = DemoMapConfig()
}

private struct DemoCurrencyConfig: CharcoalCurrencyConfig {
    let localCurrencyLocalized: String = "kr"
    let localCurrencyAccessibleLocalized: String = "kroner"
}

private struct DemoMapConfig: CharcoalMapConfig {
    let defaultMapCenterCoordinate: CLLocationCoordinate2D = .oslo
}

private extension CLLocationCoordinate2D {
    static let oslo = CLLocationCoordinate2D(latitude: 59.9171, longitude: 10.7275)
}
