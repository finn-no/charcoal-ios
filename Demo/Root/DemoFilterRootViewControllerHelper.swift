//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal

class DemoFilter {
    private struct MarketDemos {
        let market: String
        let demos: [VerticalDemo]
    }

    var filterData: FilterSetup
    var selectionDataSource = ParameterBasedFilterInfoSelectionDataSource()
    let filterSelectionTitleProvider = FilterSelectionTitleProvider()
    lazy var verticalSetup: VerticalSetupDemo = {
        let verticalsCarNorway = [VerticalDemo(id: "car-norway", title: "Biler i Norge", isCurrent: true, isExternal: false, file: "car-norway"), VerticalDemo(id: "car-abroad", title: "Biler i Utlandet", isCurrent: false, isExternal: false, file: "car-abroad")]
        let verticalsCarAbroad = [VerticalDemo(id: "car-norway", title: "Biler i Norge", isCurrent: false, isExternal: false, file: "car-norway"), VerticalDemo(id: "car-abroad", title: "Biler i Utlandet", isCurrent: true, isExternal: false, file: "car-abroad")]

        var marketDemos: [MarketDemos] = [
            [MarketDemos(market: "car-norway", demos: verticalsCarNorway), MarketDemos(market: "car-abroad", demos: verticalsCarAbroad)],
            jobVerticalDemos(),
            boatVerticalDemos(),
            mcVerticalDemos(),
            realestateVerticalDemos(),
        ].flatMap { $0 }

        let verticalDemos: [String: [VerticalDemo]] = marketDemos.reduce(into: [:]) {
            $0[$1.market] = $1.demos
        }

        return VerticalSetupDemo(verticals: verticalDemos)
    }()

    var loadedFilter: FilterInfoBuilderResult?

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
        selectionDataSource = ParameterBasedFilterInfoSelectionDataSource()
        selectionDataSource.delegate = self
        let filterInfoBuilder = FilterInfoBuilder(filter: filterData, selectionDataSource: selectionDataSource)
        loadedFilter = filterInfoBuilder.build()
    }

    static func dataFromJSONFile(named name: String) -> Data {
        let bundle = Bundle(for: DemoFilter.self)
        let path = bundle.path(forResource: name, ofType: "json")
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
}

extension DemoFilter: FilterDataSource {
    var searchQuery: SearchQueryFilterInfoType? {
        return loadedFilter?.searchQuery
    }

    var preferences: [PreferenceFilterInfoType] {
        return loadedFilter?.preferences ?? []
    }

    var filters: [FilterInfoType] {
        return loadedFilter?.filters ?? []
    }

    var verticals: [Vertical] {
        return verticalSetup.subVerticals(for: filterData.market)
    }

    var filterTitle: String {
        return filterData.filterTitle
    }

    var numberOfHits: Int {
        return filterData.hits
    }

    func numberOfHits(for filterValue: FilterValueType) -> Int {
        return loadedFilter?.filterValueLookup[filterValue.lookupKey]?.results ?? 0
    }
}

extension DemoFilter: FilterRootStateControllerDelegate {
    func filterRootStateController(_ stateController: FilterRootStateController, shouldChangeVertical vertical: Vertical) {
        guard let verticalDemo = vertical as? VerticalDemo, let verticalFile = verticalDemo.file else {
            stateController.change(to: .failed(error: .unableToLoadFilterData, action: .ok(action: { stateController.change(to: .filters) })))
            return
        }
        stateController.change(to: .loading)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self, weak stateController] in
            guard let self = self else {
                return
            }
            let filterSetup = DemoFilter.filterDataFromJSONFile(named: verticalFile)
            self.loadFilterSetup(filterSetup)
            stateController?.change(to: .loadFreshFilters(data: self))
        }
    }

    func filterRootStateControllerShouldShowResults(_: FilterRootStateController) {
        // Let user close in other ways
    }
}

extension DemoFilter: ParameterBasedFilterInfoSelectionDataSourceDelegate {
    func parameterBasedFilterInfoSelectionDataSourceDidChange(_ selectionDataSource: ParameterBasedFilterInfoSelectionDataSource) {
        print("Filter selection changed: \(selectionDataSource)")
    }
}
