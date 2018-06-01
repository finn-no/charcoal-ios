//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit

class DemoFilterDataSource: FilterDataSource {
    let filterData: FilterData

    init(filterData: FilterData) {
        self.filterData = filterData
    }

    var filterTitle: String {
        return filterData.filterTitle
    }

    var numberOfHits: Int {
        return filterData.hits
    }

    func selectionValuesForFilterInfo(at index: Int) -> [String] {
        return []
    }

    var filterInfo: [FilterInfoType] {
        let filterInfoBuilder = FilterInfoBuilder(filterData: filterData)

        return filterInfoBuilder.build()
    }

    static func dataFromJSONFile(named name: String) -> Data {
        let bundle = Bundle(for: DemoFilterDataSource.self)
        let path = bundle.path(forResource: name, ofType: "json")
        return try! Data(contentsOf: URL(fileURLWithPath: path!))
    }

    static func filterDataFromJSONFile(named name: String) -> FilterData {
        let data = dataFromJSONFile(named: name)
        let jsonDecoder = JSONDecoder()

        return try! jsonDecoder.decode(FilterData.self, from: data)
    }
}

private extension Array {
    /// Returns nil if index < count
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : .none
    }
}
