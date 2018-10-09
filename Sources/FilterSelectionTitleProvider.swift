//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public struct FilterSelectionTitleProvider {
    private let rangeCurrencyFormatter: RangeFilterValueFormatter = RangeFilterValueFormatter(isValueCurrency: true)
    private let rangeFormatter: RangeFilterValueFormatter = RangeFilterValueFormatter(isValueCurrency: false)

    public init() {
    }

    public func titlesForSelection(_ selectionData: FilterSelectionInfo) -> [String] {
        if let selectionData = selectionData as? FilterSelectionDataInfo {
            if let filter = selectionData.filter as? PreferenceInfoType {
                return titlesForSelectionValue(selectionData.value, in: filter)
            } else if let filter = selectionData.filter as? ListSelectionFilterInfoType {
                return titlesForSelectionValue(selectionData.value, in: filter)
            } else if let filter = selectionData.filter as? MultiLevelListSelectionFilterInfoType {
                return titlesForSelectionValue(selectionData.value, in: filter)
            }
        } else if let selectionData = selectionData as? FilterRangeSelectionInfo {
            return titlesForRangeSelectionValue(selectionData.value, in: selectionData.filter)
        }
        return []
    }
}

private extension FilterSelectionTitleProvider {
    func titlesForSelectionValue(_ values: [String], in filter: PreferenceInfoType) -> [String] {
        let titles = values.compactMap { (value) -> String? in
            return filter.values.first(where: { $0.value == value })?.title
        }
        return titles
    }

    func titlesForSelectionValue(_ values: [String], in filter: ListSelectionFilterInfoType) -> [String] {
        let titles = values.compactMap { (value) -> String? in
            return filter.values.first(where: { $0.value == value })?.title
        }
        return titles
    }

    func titlesForSelectionValue(_ values: [String], in filter: MultiLevelListSelectionFilterInfoType) -> [String] {
        var result = [String]()
        if values.contains(filter.value) {
            result.append(filter.title)
        }

        // TODO: This does not work correctly
        filter.filters.forEach { subFilter in
            result.append(contentsOf: titlesForSelectionValue(values, in: subFilter))
        }
        return result
    }

    func titlesForRangeSelectionValue(_ range: RangeValue, in filter: RangeFilterInfoType) -> [String] {
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
}
