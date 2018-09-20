//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public struct FilterSelectionTitleProvider {
    private let rangeCurrencyFormatter: RangeFilterValueFormatter = RangeFilterValueFormatter(isValueCurrency: true)
    private let rangeFormatter: RangeFilterValueFormatter = RangeFilterValueFormatter(isValueCurrency: false)

    public init() {
    }

    public func titlesForSelection(_ selectionData: FilterSelectionData) -> [String] {
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
}

private extension FilterSelectionTitleProvider {
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
