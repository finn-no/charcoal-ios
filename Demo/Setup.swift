//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FINNSetup
import UIKit

class Setup {
    var filterContainer: FilterContainer

    private var market: String
    private let submarkets: [Vertical]

    private init(market: String, submarkets: [Vertical]) {
        self.market = market
        self.submarkets = submarkets
        filterContainer = Setup.filterContainer(name: market)
        filterContainer.verticals = submarkets
    }

    static func filterContainer(name: String) -> FilterContainer {
        let bundle = Bundle(for: Setup.self)

        guard let path = bundle.path(forResource: name, ofType: "json") else {
            fatalError("Resource error")
        }

        let url = URL(fileURLWithPath: path)

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Data error")
        }

        let decoder = JSONDecoder()

        guard let filterSetup = try? decoder.decode(FilterSetup.self, from: data) else {
            fatalError("Decode filter error")
        }

        guard let config = FilterMarket(market: name) else {
            fatalError("Filter config error")
        }

        return filterSetup.filterContainer(using: config)
    }
}

extension Setup {
    static var bap: Setup {
        return Setup(market: "bap", submarkets: [])
    }

    static var car: Setup {
        return Setup(market: "car-norway", submarkets: [
            DemoVertical(name: "car-norway", title: "Biler i Norge", isCurrent: true),
            DemoVertical(name: "car-abroad", title: "Biler i utlandet"),
            DemoVertical(name: "mobile-home", title: "Bobil"),
            DemoVertical(name: "caravan", title: "Campingvogn"),
        ])
    }

    static var realestate: Setup {
        return Setup(market: "realestate-homes", submarkets: [
            DemoVertical(name: "realestate-homes", title: "Boliger til salgs", isCurrent: true),
            DemoVertical(name: "realestate-development", title: "Nye boliger"),
            DemoVertical(name: "realestate-plot", title: "Boligtomter"),
            DemoVertical(name: "realestate-leisure-sale", title: "Fritidsbolig til salgs"),
            DemoVertical(name: "realestate-leisure-sale-abroad", title: "Bolig i utlandet"),
            DemoVertical(name: "realestate-leisure-plot", title: "Fritidstomter"),
            DemoVertical(name: "realestate-letting", title: "Bolig til leie"),
            DemoVertical(name: "realestate-letting-wanted", title: "Bolig ønskes leid"),
            DemoVertical(name: "realestate-business-sale", title: "Næringseiendom til salgs"),
            DemoVertical(name: "realestate-business-letting", title: "Næringseiendom til leie"),
            DemoVertical(name: "realestate-business-plot", title: "Næringstomt"),
            DemoVertical(name: "company-for-sale", title: "Bedrifter til salgs"),
            DemoVertical(name: "realestate-travel-fhh", title: "Feriehus og hytter"),
        ])
    }

    static var job: Setup {
        return Setup(market: "job-full-time", submarkets: [
            DemoVertical(name: "job-full-time", title: "Alle stillinger", isCurrent: true),
            DemoVertical(name: "job-part-time", title: "Deltidsstillinger"),
            DemoVertical(name: "job-management", title: "Lederstillinger"),
        ])
    }

    static var boat: Setup {
        return Setup(market: "boat-sale", submarkets: [
            DemoVertical(name: "boat-sale", title: "Båter til salgs", isCurrent: true),
            DemoVertical(name: "boat-used-wanted", title: "Båter ønskes kjøpt"),
            DemoVertical(name: "boat-rent", title: "Båter til leie"),
            DemoVertical(name: "boat-motor", title: "Båtmotorer til salgs"),
            DemoVertical(name: "boat-parts", title: "Motordeler til salgs"),
            DemoVertical(name: "boat-parts-motor-wanted", title: "Motor/deler ønskes kjøpt"),
            DemoVertical(name: "boat-dock", title: "Båtplasser tilbys"),
            DemoVertical(name: "boat-dock-wanted", title: "Båtplasser ønskes"),
        ])
    }

    static var mc: Setup {
        return Setup(market: "mc", submarkets: [
            DemoVertical(name: "mc", title: "Motorsykler", isCurrent: true),
            DemoVertical(name: "moped-scooter", title: "Scootere og mopeder"),
            DemoVertical(name: "snowmobile", title: "Snøscootere"),
            DemoVertical(name: "atv", title: "ATV-er"),
        ])
    }

    static var b2b: Setup {
        return Setup(market: "truck", submarkets: [
            DemoVertical(name: "truck", title: "Lastebil og henger", isCurrent: true),
            DemoVertical(name: "truck-abroad", title: "Lastebil og henger i utlandet"),
            DemoVertical(name: "bus", title: "Buss og minibuss"),
            DemoVertical(name: "construction", title: "Bygg og anlegg"),
            DemoVertical(name: "agriculture-tractor", title: "Traktor"),
            DemoVertical(name: "agriculture-thresher", title: "Tresker"),
            DemoVertical(name: "agriculture-tool", title: "Landbruksredskap"),
            DemoVertical(name: "van-abroad", title: "Varebiler i Norge"),
            DemoVertical(name: "van-norway", title: "Varebiler i utlanet"),
        ])
    }
}
