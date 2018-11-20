//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal

class DemoFilter {
    let filterData: FilterSetup
    let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource()
    let filterSelectionTitleProvider = FilterSelectionTitleProvider()
    var verticalSetup: VerticalSetupDemo = {
        let verticalsCarNorway = [VerticalDemo(id: "car-norway", title: "Biler i Norge", isCurrent: true, isExternal: false), VerticalDemo(id: "car-abroad", title: "Biler i Utlandet", isCurrent: false, isExternal: false)]
        let verticalsCarAbroad = [VerticalDemo(id: "car-norway", title: "Biler i Norge", isCurrent: false, isExternal: false), VerticalDemo(id: "car-abroad", title: "Biler i Utlandet", isCurrent: true, isExternal: false)]
        let verticalsRealestateHomes = [
            VerticalDemo(id: "realestate-homes", title: "Bolig til salgs", isCurrent: true, isExternal: false),
            VerticalDemo(id: "realestate-development", title: "Nye boliger", isCurrent: false, isExternal: false),
            VerticalDemo(id: "realestate-plot", title: "Boligtomter", isCurrent: false, isExternal: false),
            VerticalDemo(id: "realestate-leisure-sale", title: "Fritidsbolig til salgs", isCurrent: false, isExternal: false),
            VerticalDemo(id: "realestate-leisure-sale-abroad", title: "Bolig i utlandet", isCurrent: false, isExternal: false),
            VerticalDemo(id: "realestate-leisure-plot", title: "Fritidstomter", isCurrent: false, isExternal: false),
            VerticalDemo(id: "realestate-letting", title: "Bolig til leie", isCurrent: false, isExternal: false),
            VerticalDemo(id: "realestate-letting-wanted", title: "Bolig ønskes leid", isCurrent: false, isExternal: false),
            VerticalDemo(id: "realestate-business-sale", title: "Næringseiendom til salgs", isCurrent: false, isExternal: false),
            VerticalDemo(id: "realestate-business-letting", title: "Næringseiendom til leie", isCurrent: false, isExternal: false),
            VerticalDemo(id: "realestate-business-plot", title: "Næringstomt", isCurrent: false, isExternal: false),
            VerticalDemo(id: "realestate-company-for-sale", title: "Bedrifter til salgs", isCurrent: false, isExternal: false),
            VerticalDemo(id: "realestate-travel-fhh", title: "Feriehus og hytter", isCurrent: false, isExternal: true),
        ]

        let verticals = VerticalSetupDemo(verticals: [
            "car-norway": verticalsCarNorway,
            "car-abroad": verticalsCarAbroad,
            "realestate-homes": verticalsRealestateHomes,
        ])
        return verticals
    }()

    lazy var loadedFilter: FilterInfoBuilderResult? = {
        let filterInfoBuilder = FilterInfoBuilder(filter: filterData, selectionDataSource: selectionDataSource)

        return filterInfoBuilder.build()
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
