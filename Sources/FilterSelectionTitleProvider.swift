//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public struct FilterSelectionTitleProvider {
    public init() {
    }

    public func titleForSelection(_ selectionData: FilterSelectionInfo) -> String {
        if let selectionData = selectionData as? FilterSelectionDataInfo {
            if selectionData.filter is ListSelectionFilterInfoType {
                return titlesForListFilterSelectionValue(selectionData)
            } else {
                return titleForMultiLevelFilterSelectionValue(selectionData)
            }
        } else if let selectionData = selectionData as? FilterRangeSelectionInfo {
            return titlesForRangeSelectionValue(selectionData.value, in: selectionData.filter)
        } else if let selectionData = selectionData as? FilterStepperSelectionInfo {
            return titleForStepperSelectionValue(selectionData.value, in: selectionData.filter)
        }
        return ""
    }
}

private extension FilterSelectionTitleProvider {
    func titlesForListFilterSelectionValue(_ selection: FilterSelectionDataInfo) -> String {
        guard let listFilter = selection.filter as? ListSelectionFilterInfoType else {
            return ""
        }

        let selectedValue = listFilter.values.first(where: { $0.value == selection.value })
        return selectedValue?.title ?? ""
    }

    func titleForMultiLevelFilterSelectionValue(_ selection: FilterSelectionDataInfo) -> String {
        return selection.filter.title
    }

    func titleForStepperSelectionValue(_ value: Int, in filter: StepperFilterInfoType) -> String {
        return "\(value)+"
    }

    func titlesForRangeSelectionValue(_ range: RangeValue, in filter: RangeFilterInfoType) -> String {
        let formatter = RangeFilterValueFormatter(isValueCurrency: filter.isCurrencyValueRange, unit: filter.unit)
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
