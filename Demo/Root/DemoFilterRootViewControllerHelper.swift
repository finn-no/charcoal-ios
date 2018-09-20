//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit

class DemoFilter {
    let filterData: FilterSetup
    let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource()
    let rangeCurrencyFormatter = RangeFilterValueFormatter(isValueCurrency: true)
    let rangeFormatter = RangeFilterValueFormatter(isValueCurrency: false)

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

    func displaySelectionValuesForFilterInfoAndSubFilters(at index: Int) -> [String] {
        guard let filter = filterInfo[safe: index] else {
            return []
        }
        let selectionValues = selectionDataSource.valueAndSubLevelValues(for: filter)

        var result = [String]()
        for selectionData in selectionValues {
            result.append(contentsOf: titleForSelectionValue(selectionData))
        }
        return result
    }

    func titleForSelectionValue(_ selectionData: FilterSelectionData) -> [String] {
        if let filter = selectionData.filter as? PreferenceInfoType {
            return titlesForSelectionValue(selectionData.value, in: filter)
        } else if let filter = selectionData.filter as? ListSelectionFilterInfoType {
            return titlesForSelectionValue(selectionData.value, in: filter)
        } else if let filter = selectionData.filter as? MultiLevelListSelectionFilterInfoType {
            return titlesForSelectionValue(selectionData.value, in: filter)
        } else if let filter = selectionData.filter as? RangeFilterInfoType {
            return titlesForSelectionValue(selectionData.value, in: filter)
        }
        return []
    }

    func titlesForSelectionValue(_ selectionValue: FilterSelectionValue, in filter: PreferenceInfoType) -> [String] {
        switch selectionValue {
        case let .singleSelection(value):
            if let valueType = filter.values.first(where: { $0.value == value }) {
                return [valueType.title]
            }
        case let .multipleSelection(values):
            let titles = values.compactMap { (value) -> String? in
                return filter.values.first(where: { $0.value == value })?.title
            }
            return titles
        case .rangeSelection:
            break
        }
        return []
    }

    func titlesForSelectionValue(_ selectionValue: FilterSelectionValue, in filter: ListSelectionFilterInfoType) -> [String] {
        switch selectionValue {
        case let .singleSelection(value):
            if let valueType = filter.values.first(where: { $0.value == value }) {
                return [valueType.title]
            }
        case let .multipleSelection(values):
            let titles = values.compactMap { (value) -> String? in
                return filter.values.first(where: { $0.value == value })?.title
            }
            return titles
        case .rangeSelection:
            break
        }
        return []
    }

    func titlesForSelectionValue(_ selectionValue: FilterSelectionValue, in filter: MultiLevelListSelectionFilterInfoType) -> [String] {
        var result = [String]()
        if let filterValue = filter.value {
            switch selectionValue {
            case let .singleSelection(value):
                if filterValue == value {
                    result.append(filter.title)
                }
            case let .multipleSelection(values):
                if values.contains(filterValue) {
                    result.append(filter.title)
                }
            case .rangeSelection:
                break
            }
        }
        filter.filters.forEach { subFilter in
            result.append(contentsOf: titlesForSelectionValue(selectionValue, in: subFilter))
        }
        return result
    }

    func titlesForSelectionValue(_ selectionValue: FilterSelectionValue, in filter: RangeFilterInfoType) -> [String] {
        if case let .rangeSelection(range) = selectionValue {
            let formatter: RangeFilterValueFormatter
            if filter.isCurrencyValueRange {
                formatter = rangeCurrencyFormatter
            } else {
                formatter = rangeFormatter
            }
            switch range {
            case let .minimum(lowValue):
                let lowValue = formatter.string(from: lowValue) ?? ""
                return ["\(lowValue) - ..."]
            case let .maximum(highValue):
                let highValue = formatter.string(from: highValue) ?? ""
                return ["... - \(highValue)"]
            case let .closed(lowValue, highValue):
                let lowValue = formatter.string(from: lowValue) ?? ""
                let highValue = formatter.string(from: highValue) ?? ""
                return ["\(lowValue) - \(highValue)"]
            }
        }
        return []
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
