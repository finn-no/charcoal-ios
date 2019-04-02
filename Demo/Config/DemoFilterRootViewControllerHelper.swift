//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FINNSetup

class DemoFilter {
    private struct MarketDemos {
        let market: String
        let demos: [VerticalDemo]
    }

    var filterData: FilterSetup
    lazy var verticalSetup: VerticalSetupDemo = {
        var marketDemos: [MarketDemos] = [
            carVerticalDemos(),
            jobVerticalDemos(),
            boatVerticalDemos(),
            mcVerticalDemos(),
            realestateVerticalDemos(),
            b2bVerticalDemos(),
        ].flatMap { $0 }

        let verticalDemos: [String: [VerticalDemo]] = marketDemos.reduce(into: [:]) {
            $0[$1.market] = $1.demos
        }

        return VerticalSetupDemo(verticals: verticalDemos)
    }()

    private lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.currencySymbol = ""
        formatter.locale = Locale(identifier: "nb_NO")
        formatter.maximumFractionDigits = 0

        return formatter
    }()

    init(filter: FilterSetup) {
        filterData = filter
        loadFilterSetup(filter)
    }

    func loadFilterSetup(_ filterSetup: FilterSetup) {
        filterData = filterSetup
    }

    static func dataFromJSONFile(named name: String) -> Data {
        let bundle = Bundle(for: DemoFilter.self)
        let path = bundle.path(forResource: name, ofType: "json")
        // swiftlint:disable force_try
        return try! Data(contentsOf: URL(fileURLWithPath: path!))
    }

    static func filterDataFromJSONFile(named name: String) -> FilterSetup {
        let data = dataFromJSONFile(named: name)

        // Use this to test decoding directly from data
        // let jsonDecoder = JSONDecoder()
        // return try! jsonDecoder.decode(FilterSetup.self, from: data)

        // Use this to test decoding from pre-parsed data (dictionary)
        let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        return FilterSetup.decode(from: jsonObj as? [AnyHashable: Any])!
    }

    // Market vertical creation.

    private func createVerticalDemos<T: RawRepresentable>(from markets: [(market: T, title: String)], isExternal: ((T) -> Bool)? = nil) -> [MarketDemos] where T.RawValue == String {
        return markets.map { market, _ in
            let demos = markets.map { (subMarket, title) -> VerticalDemo in
                let isExternal = isExternal?(subMarket) ?? false
                return VerticalDemo(id: subMarket.rawValue, title: title, isCurrent: subMarket == market, isExternal: isExternal, file: subMarket.rawValue)
            }
            return MarketDemos(market: market.rawValue, demos: demos)
        }
    }

    private func carVerticalDemos() -> [MarketDemos] {
        let markets: [(market: FilterMarketCar, title: String)] = [
            (market: .norway, title: "Biler i Norge"),
            (market: .abroad, title: "Biler i utlandet"),
            (market: .mobileHome, title: "Bobil"),
            (market: .caravan, title: "Campingvogn"),
        ]

        return createVerticalDemos(from: markets)
    }

    private func boatVerticalDemos() -> [MarketDemos] {
        let markets: [(market: FilterMarketBoat, title: String)] = [
            (market: .boatSale, title: "Båter til salgs"),
            (market: .boatUsedWanted, title: "Båt ønskes kjøpt"),
            (market: .boatRent, title: "Båter til leie"),
            (market: .boatMotor, title: "Båtmotorer til salgs"),
            (market: .boatParts, title: "Motordeler til salgs"),
            (market: .boatPartsMotorWanted, title: "Motor/deler ønskes kjøpt"),
            (market: .boatDock, title: "Båtplasser tilbys"),
            (market: .boatDockWanted, title: "Båtplasser ønskes"),
        ]

        return createVerticalDemos(from: markets)
    }

    private func jobVerticalDemos() -> [MarketDemos] {
        let markets: [(market: FilterMarketJob, title: String)] = [
            (market: .fullTime, title: "Alle stillinger"),
            (market: .partTime, title: "Deltidsstillinger"),
            (market: .management, title: "Lederstillinger"),
        ]

        return createVerticalDemos(from: markets)
    }

    private func mcVerticalDemos() -> [MarketDemos] {
        let markets: [(market: FilterMarketMC, title: String)] = [
            (market: .mc, title: "Motorsykler"),
            (market: .mopedScooter, title: "Scootere og mopeder"),
            (market: .snowmobile, title: "Snøscootere"),
            (market: .atv, title: "ATV-er"),
        ]

        return createVerticalDemos(from: markets)
    }

    private func realestateVerticalDemos() -> [MarketDemos] {
        let markets: [(market: FilterMarketRealestate, title: String)] = [
            (market: .homes, title: "Boliger til salgs"),
            (market: .development, title: "Nye boliger"),
            (market: .plot, title: "Boligtomter"),
            (market: .leisureSale, title: "Fritidsbolig til salgs"),
            (market: .leisureSaleAbroad, title: "Bolig i utlandet"),
            (market: .leisurePlot, title: "Fritidstomter"),
            (market: .letting, title: "Bolig til leie"),
            (market: .lettingWanted, title: "Bolig ønskes leid"),
            (market: .businessSale, title: "Næringseiendom til salgs"),
            (market: .businessLetting, title: "Næringseiendom til leie"),
            (market: .businessPlot, title: "Næringstomt"),
            (market: .companyForSale, title: "Bedrifter til salgs"),
            (market: .travelFhh, title: "Feriehus og hytter"),
        ]

        return createVerticalDemos(from: markets, isExternal: { market in
            let isExternal = market == .travelFhh
            return isExternal
        })
    }

    private func b2bVerticalDemos() -> [MarketDemos] {
        let markets: [(market: FilterMarketB2B, title: String)] = [
            (market: .truck, title: "Lastebil og henger"),
            (market: .truckAbroad, title: "Lastebil og henger i utlandet"),
            (market: .bus, title: "Buss og minibuss"),
            (market: .construction, title: "Bygg og anlegg"),
            (market: .agricultureTractor, title: "Traktor"),
            (market: .agricultureThresher, title: "Tresker"),
            (market: .agricultureTools, title: "Landbruksredskap"),
            (market: .vanNorway, title: "Varebiler i Norge"),
            (market: .vanAbroad, title: "Varebiler i utlandet"),
        ]

        return createVerticalDemos(from: markets)
    }
}
