//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit

class DemoFilter {
    let filterData: FilterSetup
    let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource()

    lazy var loadedFilterInfo: [FilterInfoType] = {
        let filterInfoBuilder = FilterInfoBuilder(filter: filterData)

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
    var filterTitle: String {
        return filterData.filterTitle
    }

    var numberOfHits: Int {
        return filterData.hits
    }

    var filterInfo: [FilterInfoType] {
        return loadedFilterInfo
    }

    func selectionValuesForFilterInfoAndSubFilters(at index: Int) -> [String] {
        guard let filter = filterInfo[safe: index] else {
            return []
        }
        let selectionValues = selectionDataSource.valueAndSubLevelValues(for: filter)

        var result = [String]()

        for selectionValue in selectionValues {
            switch selectionValue {
            case let .singleSelection(value):
                result = [value]
            case let .multipleSelection(values):
                result = values
            case let .rangeSelection(range):
                switch range {
                case let .minimum(lowValue):
                    result = ["\(lowValue) - ..."]
                case let .maximum(highValue):
                    result = ["... - \(highValue)"]
                case let .closed(lowValue, highValue):
                    result = ["\(lowValue) - \(highValue)"]
                }
            }
        }
        return result
    }
}

extension DemoFilter: FilterDelegate {
    func filterSelectionValueChanged(_ filterSelectionValue: FilterSelectionValue, forFilterWithFilterInfo filterInfo: FilterInfoType) {
        if let _ = filterInfo as? ParameterBasedFilterInfo {
            selectionDataSource.setValue(filterSelectionValue, for: filterInfo)
            print(selectionDataSource)
        }
    }

    func applyFilterSelectionValue(_ filterSelectionValue: FilterSelectionValue?, forFilterWithFilterInfo filterInfo: FilterInfoType) {
        if let _ = filterInfo as? ParameterBasedFilterInfo {
            selectionDataSource.setValue(filterSelectionValue, for: filterInfo)
            print(selectionDataSource)
        }
    }
}
