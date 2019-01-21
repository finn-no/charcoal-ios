//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal

class DemoFilter {
    var filterData: FilterSetup
    var selectionDataSource = ParameterBasedFilterInfoSelectionDataSource()
    let filterSelectionTitleProvider = FilterSelectionTitleProvider()
    var verticalSetup: VerticalSetupDemo = {
        let verticalsCarNorway = [VerticalDemo(id: "car-norway", title: "Biler i Norge", isCurrent: true, isExternal: false, file: "car-norway"), VerticalDemo(id: "car-abroad", title: "Biler i Utlandet", isCurrent: false, isExternal: false, file: "car-abroad")]
        let verticalsCarAbroad = [VerticalDemo(id: "car-norway", title: "Biler i Norge", isCurrent: false, isExternal: false, file: "car-norway"), VerticalDemo(id: "car-abroad", title: "Biler i Utlandet", isCurrent: true, isExternal: false, file: "car-abroad")]
        let verticalsRealestateHomes = [
            VerticalDemo(id: "realestate-homes", title: "Bolig til salgs", isCurrent: true, isExternal: false, file: "realestate-homes"),
            VerticalDemo(id: "realestate-development", title: "Nye boliger", isCurrent: false, isExternal: false, file: nil),
            VerticalDemo(id: "realestate-plot", title: "Boligtomter", isCurrent: false, isExternal: false, file: nil),
            VerticalDemo(id: "realestate-leisure-sale", title: "Fritidsbolig til salgs", isCurrent: false, isExternal: false, file: nil),
            VerticalDemo(id: "realestate-leisure-sale-abroad", title: "Bolig i utlandet", isCurrent: false, isExternal: false, file: nil),
            VerticalDemo(id: "realestate-leisure-plot", title: "Fritidstomter", isCurrent: false, isExternal: false, file: nil),
            VerticalDemo(id: "realestate-letting", title: "Bolig til leie", isCurrent: false, isExternal: false, file: nil),
            VerticalDemo(id: "realestate-letting-wanted", title: "Bolig ønskes leid", isCurrent: false, isExternal: false, file: nil),
            VerticalDemo(id: "realestate-business-sale", title: "Næringseiendom til salgs", isCurrent: false, isExternal: false, file: nil),
            VerticalDemo(id: "realestate-business-letting", title: "Næringseiendom til leie", isCurrent: false, isExternal: false, file: nil),
            VerticalDemo(id: "realestate-business-plot", title: "Næringstomt", isCurrent: false, isExternal: false, file: nil),
            VerticalDemo(id: "realestate-company-for-sale", title: "Bedrifter til salgs", isCurrent: false, isExternal: false, file: nil),
            VerticalDemo(id: "realestate-travel-fhh", title: "Feriehus og hytter", isCurrent: false, isExternal: true, file: nil),
        ]
        let verticalsMC = [
            VerticalDemo(id: "mc", title: "Motorsykler", isCurrent: true, isExternal: false, file: "mc"),
            VerticalDemo(id: "moped-scooter", title: "Scootere og mopeder", isCurrent: false, isExternal: false, file: "moped-scooter"),
            VerticalDemo(id: "snowmobile", title: "Snøscootere", isCurrent: false, isExternal: false, file: "snowmobile"),
            VerticalDemo(id: "atv", title: "ATV-er", isCurrent: false, isExternal: false, file: "atv"),
        ]
        let verticalsMopedScooter = [
            VerticalDemo(id: "mc", title: "Motorsykler", isCurrent: false, isExternal: false, file: "mc"),
            VerticalDemo(id: "moped-scooter", title: "Scootere og mopeder", isCurrent: true, isExternal: false, file: "moped-scooter"),
            VerticalDemo(id: "snowmobile", title: "Snøscootere", isCurrent: false, isExternal: false, file: "snowmobile"),
            VerticalDemo(id: "atv", title: "ATV-er", isCurrent: false, isExternal: false, file: "atv"),
        ]
        let verticalsSnowmobile = [
            VerticalDemo(id: "mc", title: "Motorsykler", isCurrent: false, isExternal: false, file: "mc"),
            VerticalDemo(id: "moped-scooter", title: "Scootere og mopeder", isCurrent: false, isExternal: false, file: "moped-scooter"),
            VerticalDemo(id: "snowmobile", title: "Snøscootere", isCurrent: true, isExternal: false, file: "snowmobile"),
            VerticalDemo(id: "atv", title: "ATV-er", isCurrent: false, isExternal: false, file: "atv"),
        ]
        let verticalsATV = [
            VerticalDemo(id: "mc", title: "Motorsykler", isCurrent: false, isExternal: false, file: "mc"),
            VerticalDemo(id: "moped-scooter", title: "Scootere og mopeder", isCurrent: false, isExternal: false, file: "moped-scooter"),
            VerticalDemo(id: "snowmobile", title: "Snøscootere", isCurrent: false, isExternal: false, file: "snowmobile"),
            VerticalDemo(id: "atv", title: "ATV-er", isCurrent: true, isExternal: false, file: "atv"),
        ]
        let verticalsJobFullTime = [
            VerticalDemo(id: "job-full-time", title: "Alle stillinger", isCurrent: true, isExternal: false, file: "job-full-time"),
            VerticalDemo(id: "job-part-time", title: "Deltidsstillinger", isCurrent: false, isExternal: false, file: "job-part-time"),
            VerticalDemo(id: "job-management", title: "Lederstillinger", isCurrent: false, isExternal: false, file: "job-management"),
        ]
        let verticalsJobPartTime = [
            VerticalDemo(id: "job-full-time", title: "Alle stillinger", isCurrent: false, isExternal: false, file: "job-full-time"),
            VerticalDemo(id: "job-part-time", title: "Deltidsstillinger", isCurrent: true, isExternal: false, file: "job-part-time"),
            VerticalDemo(id: "job-management", title: "Lederstillinger", isCurrent: false, isExternal: false, file: "job-management"),
        ]
        let verticalsJobManagement = [
            VerticalDemo(id: "job-full-time", title: "Alle stillinger", isCurrent: false, isExternal: false, file: "job-full-time"),
            VerticalDemo(id: "job-part-time", title: "Deltidsstillinger", isCurrent: false, isExternal: false, file: "job-part-time"),
            VerticalDemo(id: "job-management", title: "Lederstillinger", isCurrent: true, isExternal: false, file: "job-management"),
        ]

        let verticals = VerticalSetupDemo(verticals: [
            "car-norway": verticalsCarNorway,
            "car-abroad": verticalsCarAbroad,
            "realestate-homes": verticalsRealestateHomes,
            "mc": verticalsMC,
            "moped-scooter": verticalsMopedScooter,
            "snowmobile": verticalsSnowmobile,
            "atv": verticalsATV,
            "job-full-time": verticalsJobFullTime,
            "job-part-time": verticalsJobPartTime,
            "job-management": verticalsJobManagement,
        ])
        return verticals
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
