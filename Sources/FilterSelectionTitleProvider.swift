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
            if selectionData.filter is ListSelectionFilterInfoType {
                return titlesForListFilterSelectionValue(selectionData)
            } else {
                return [titleForMultiLevelFilterSelectionValue(selectionData)]
            }
        } else if let selectionData = selectionData as? FilterRangeSelectionInfo {
            return [titlesForRangeSelectionValue(selectionData.value, in: selectionData.filter)]
        }
        return []
    }
}

private extension FilterSelectionTitleProvider {
    func titlesForListFilterSelectionValue(_ selection: FilterSelectionDataInfo) -> [String] {
        guard let listFilter = selection.filter as? ListSelectionFilterInfoType else {
            return []
        }

        let selectedValues = listFilter.values.filter({ selection.value.contains($0.value) })
        return selectedValues.map({ $0.title })
    }

    func titleForMultiLevelFilterSelectionValue(_ selection: FilterSelectionDataInfo) -> String {
        return selection.filter.title
    }

    func titlesForRangeSelectionValue(_ range: RangeValue, in filter: RangeFilterInfoType) -> String {
        let formatter: RangeFilterValueFormatter
        if filter.isCurrencyValueRange {
            formatter = rangeCurrencyFormatter
        } else {
            formatter = rangeFormatter
        }
        switch range {
        case let .minimum(lowValue):
            let lowValue = formatter.string(from: lowValue) ?? ""
            return "\(lowValue) - ..."
        case let .maximum(highValue):
            let highValue = formatter.string(from: highValue) ?? ""
            return "... - \(highValue)"
        case let .closed(lowValue, highValue):
            let lowValue = formatter.string(from: lowValue) ?? ""
            let highValue = formatter.string(from: highValue) ?? ""
            return "\(lowValue) - \(highValue)"
        }
    }
}
