//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit

class DemoFilter {
    let filterData: FilterSetup

    lazy var loadedFilterInfo: [FilterInfoType] = {
        let filterInfoBuilder = FilterInfoBuilder(filter: filterData)

        return filterInfoBuilder.build()
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
    var filterTitle: String {
        return filterData.filterTitle
    }

    var numberOfHits: Int {
        return filterData.hits
    }

    var filterInfo: [FilterInfoType] {
        return loadedFilterInfo
    }

    func selectionValuesForFilterInfo(at index: Int) -> [String] {
        return []
    }
}

extension DemoFilter: FilterDelegate {
    func filterSelectionValueChanged(_ filterSelectionValue: FilterSelectionValue, forFilterWithFilterInfo filterInfo: FilterInfoType) {
        if let keyedFilter = filterInfo as? KeyedFilterInfo {
            print("filterSelectionValueChanged for filter with key: \(keyedFilter.key.rawValue). Value: \(String(describing: filterSelectionValue))")
        }
    }

    func applyFilterSelectionValue(_ filterSelectionValue: FilterSelectionValue?, forFilterWithFilterInfo filterInfo: FilterInfoType) {
        if let keyedFilter = filterInfo as? KeyedFilterInfo {
            print("filterSelectionValueChanged for filter with key: \(keyedFilter.key.rawValue). Value: \(String(describing: filterSelectionValue))")
        }
    }
}
