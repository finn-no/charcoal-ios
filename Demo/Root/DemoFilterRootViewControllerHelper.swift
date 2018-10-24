//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit

class DemoFilter {
    let filterData: FilterSetup
    let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource()
    let filterSelectionTitleProvider = FilterSelectionTitleProvider()
    var verticalSetup: VerticalSetupDemo = {
        let verticalsCarNorway = [VerticalDemo(id: "car-norway", title: "Biler i Norge", isCurrent: true), VerticalDemo(id: "car-abroad", title: "Biler i Utlandet", isCurrent: false)]
        let verticalsCarAbroad = [VerticalDemo(id: "car-norway", title: "Biler i Norge", isCurrent: false), VerticalDemo(id: "car-abroad", title: "Biler i Utlandet", isCurrent: true)]
        let verticalsRealestateHomes = [
            VerticalDemo(id: "realestate-homes", title: "Bolig til salgs", isCurrent: true),
            VerticalDemo(id: "1", title: "Nye boliger", isCurrent: false),
            VerticalDemo(id: "2", title: "Boligtomter", isCurrent: false),
            VerticalDemo(id: "3", title: "Fritidsbolig til salgs", isCurrent: false),
            VerticalDemo(id: "1", title: "Bolig i utlandet", isCurrent: false),
            VerticalDemo(id: "1", title: "Fritidstomter", isCurrent: false),
            VerticalDemo(id: "1", title: "Bolig til leie", isCurrent: false),
            VerticalDemo(id: "1", title: "Bolig ønskes leid", isCurrent: false),
            VerticalDemo(id: "1", title: "Næringseiendom til salgs", isCurrent: false),
            VerticalDemo(id: "1", title: "Næringseiendom til leie", isCurrent: false),
            VerticalDemo(id: "1", title: "Næringstomt", isCurrent: false),
            VerticalDemo(id: "1", title: "Bedrifter til salgs", isCurrent: false),
            VerticalDemo(id: "1", title: "Feriehus og hytter", isCurrent: false),
        ]

        let verticals = VerticalSetupDemo(verticals: [
            "car-norway": verticalsCarNorway,
            "car-abroad": verticalsCarAbroad,
            "realestate-homes": verticalsRealestateHomes,
        ])
        return verticals
    }()

    lazy var loadedFilterInfo: [FilterInfoType] = {
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
        let jsonDecoder = JSONDecoder()

        return try! jsonDecoder.decode(FilterSetup.self, from: data)
    }
}

extension DemoFilter: FilterDataSource {
    var verticals: [Vertical] {
        return verticalSetup.subVerticals(for: filterData.market)
    }

    var filterTitle: String {
        return filterData.filterTitle
    }

    var numberOfHits: Int {
        return filterData.hits
    }

    var filterInfo: [FilterInfoType] {
        return loadedFilterInfo
    }

    func selectionValueTitlesForFilterInfoAndSubFilters(at index: Int) -> [String] {
        guard let filter = filterInfo[safe: index] else {
            return []
        }
        let selectionValues = selectionDataSource.valueAndSubLevelValues(for: filter)

        var result = [String]()
        for selectionData in selectionValues {
            result.append(contentsOf: filterSelectionTitleProvider.titlesForSelection(selectionData))
        }
        return result
    }
}
