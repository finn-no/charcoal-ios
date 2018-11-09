//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class ParameterBasedFilterInfoSelectionDataSource: NSObject {
    private(set) var selectionValues: [String: [String]]
    var multiLevelFilterLookup: [MultiLevelListSelectionFilterInfo.LookupKey: MultiLevelListSelectionFilterInfo] = [:]

    public init(queryItems: [URLQueryItem]) {
        var selectionValues = [String: [String]]()
        for qi in queryItems {
            guard let value = qi.value else {
                continue
            }
            if let values = selectionValues[qi.name] {
                selectionValues[qi.name] = values + [value]
            } else {
                selectionValues[qi.name] = [value]
            }
        }
        self.selectionValues = selectionValues
    }

    public convenience override init() {
        self.init(queryItems: [URLQueryItem]())
    }

    public override var description: String {
        return selectionValues.compactMap({ (keyAndValues) -> String? in
            return keyAndValues.value.map({ keyAndValues.key + "=" + $0 })
                .joined(separator: "&")
        }).joined(separator: "&")
    }
}

private extension ParameterBasedFilterInfoSelectionDataSource {
    func setSelectionValues(_ values: [String], for key: String) {
        selectionValues[key] = values
    }

    func setSelectionValue(_ value: String, for key: String) {
        setSelectionValues([value], for: key)
    }

    func addSelectionValue(_ value: String, for key: String) {
        var values: [String]
        if let previousValues = selectionValues[key] {
            values = previousValues
        } else {
            values = []
        }
        values.append(value)
        setSelectionValues(values, for: key)
    }

    func removeSelectionValue(_ value: String, for key: String) {
        if let previousValues = selectionValues[key] {
            setSelectionValues(previousValues.filter({ $0 != value }), for: key)
        }
    }

    func removeSelectionValues(_ key: String) {
        selectionValues.removeValue(forKey: key)
    }

    func selectionValues(for name: String) -> [String] {
        return selectionValues[name] ?? []
    }

    func filterParameter(for filterInfo: FilterInfoType) -> String? {
        if let filter = filterInfo as? ParameterBasedFilterInfo {
            return filter.parameterName
        }
        return nil
    }

    func setStringValue(_ value: String, for key: String) {
        setSelectionValue(value, for: key)
    }

    func setRangeSelectionValue(_ range: RangeValue, for key: String) {
        let lowKey = rangeFilterKeyLow(fromBaseKey: key)
        let highKey = rangeFilterKeyHigh(fromBaseKey: key)
        switch range {
        case let .minimum(lowValue):
            setStringValue(lowValue.description, for: lowKey)
            removeSelectionValues(highKey)
        case let .maximum(highValue):
            removeSelectionValues(lowKey)
            setStringValue(highValue.description, for: highKey)
        case let .closed(lowValue, highValue):
            setStringValue(lowValue.description, for: lowKey)
            setStringValue(highValue.description, for: highKey)
        }
    }

    func intOrNil(from value: String?) -> Int? {
        guard let value = value else {
            return nil
        }
        return Int(value)
    }

    func updateSelectionStateForParents(of multiLevelFilter: MultiLevelListSelectionFilterInfo) {
        guard let parent = multiLevelFilter.parent as? MultiLevelListSelectionFilterInfo else {
            return
        }
        parent.updateSelectionState(self)
        updateSelectionStateForParents(of: parent)
    }

    func isAncestor(_ ancestor: MultiLevelListSelectionFilterInfo, to multiLevelFilter: MultiLevelListSelectionFilterInfoType?) -> Bool {
        guard let multiLevelFilter = multiLevelFilter as? MultiLevelListSelectionFilterInfo else {
            return false
        }
        guard let multiLevelFilterParent = multiLevelFilter.parent as? MultiLevelListSelectionFilterInfo else {
            return false
        }
        if multiLevelFilterParent === ancestor {
            return true
        }
        return isAncestor(ancestor, to: multiLevelFilterParent)
    }

    func rangeFilterKeyLow(fromBaseKey filterKey: String) -> String {
        return filterKey + "_from"
    }

    func rangeFilterKeyHigh(fromBaseKey filterKey: String) -> String {
        return filterKey + "_to"
    }
}

extension ParameterBasedFilterInfoSelectionDataSource: FilterSelectionDataSource {
    public func selectionState(_ filterInfo: MultiLevelListSelectionFilterInfoType) -> MultiLevelListItemSelectionState {
        guard let filter = filterInfo as? MultiLevelListSelectionFilterInfo else {
            return .none
        }
        return filter.selectionState
    }

    public func valueAndSubLevelValues(for filterInfo: FilterInfoType) -> [FilterSelectionInfo] {
        if let multiLevelFilterInfo = filterInfo as? MultiLevelListSelectionFilterInfo {
            guard multiLevelFilterInfo.selectionState != .none else {
                return []
            }
            var values = [FilterSelectionInfo]()

            selectionValues.forEach { selectionValuesAndKey in
                selectionValuesAndKey.value.forEach({ selectionValue in
                    if let selectedFilterInfo = multiLevelFilterLookup[MultiLevelListSelectionFilterInfo.LookupKey(parameterName: selectionValuesAndKey.key, value: selectionValue)] {
                        if selectedFilterInfo === multiLevelFilterInfo || isAncestor(multiLevelFilterInfo, to: selectedFilterInfo) {
                            values.append(FilterSelectionDataInfo(filter: selectedFilterInfo, value: [selectedFilterInfo.value]))
                        }
                    }
                })
            }

            return values
        } else if let rangeFilterInfo = filterInfo as? RangeFilterInfo, let value = rangeValue(for: rangeFilterInfo) {
            return [FilterRangeSelectionInfo(filter: rangeFilterInfo, value: value)]
        } else if let stepperFilterInfo = filterInfo as? StepperFilterInfo, let value = stepperValue(for: stepperFilterInfo) {
            return [FilterStepperSelectionInfo(filter: stepperFilterInfo, value: value)]
        } else if let rootValue = value(for: filterInfo) {
            return [FilterSelectionDataInfo(filter: filterInfo, value: rootValue)]
        }
        return []
    }

    public func value(for filterInfo: FilterInfoType) -> [String]? {
        guard let filterKey = filterParameter(for: filterInfo) else {
            return nil
        }
        if filterInfo is RangeFilterInfoType {
        } else {
            let values = selectionValues(for: filterKey)

            if values.count < 1 {
                return nil
            }
            if values.count > 1 {
                return values
            } else {
                if let value = values.first {
                    return [value]
                }
            }
        }
        return nil
    }

    public func setValue(_ filterSelectionValue: [String]?, for filterInfo: FilterInfoType) {
        guard let filterKey = filterParameter(for: filterInfo) else {
            return
        }
        if let filterSelectionValue = filterSelectionValue {
            setSelectionValues(filterSelectionValue, for: filterKey)
        } else {
            removeSelectionValues(filterKey)
        }

        if let multiLevelFilter = filterInfo as? MultiLevelListSelectionFilterInfo {
            multiLevelFilter.updateSelectionState(self)
            updateSelectionStateForParents(of: multiLevelFilter)
        }

        DebugLog.write(self)
    }

    public func addValue(_ value: String, for filterInfo: FilterInfoType) {
        guard let filterKey = filterParameter(for: filterInfo) else {
            return
        }
        addSelectionValue(value, for: filterKey)

        if let multiLevelFilter = filterInfo as? MultiLevelListSelectionFilterInfo {
            multiLevelFilter.updateSelectionState(self)
            updateSelectionStateForParents(of: multiLevelFilter)
        }

        DebugLog.write(self)
    }

    public func clearAll(for filterInfo: FilterInfoType) {
        guard let filterKey = filterParameter(for: filterInfo) else {
            return
        }
        if filterInfo is RangeFilterInfoType {
            removeSelectionValues(rangeFilterKeyLow(fromBaseKey: filterKey))
            removeSelectionValues(rangeFilterKeyHigh(fromBaseKey: filterKey))
        } else if filterInfo is StepperFilterInfoType {
            removeSelectionValues(rangeFilterKeyLow(fromBaseKey: filterKey))
        } else {
            removeSelectionValues(filterKey)

            if let multiLevelFilter = filterInfo as? MultiLevelListSelectionFilterInfo {
                multiLevelFilter.updateSelectionState(self)
                updateSelectionStateForParents(of: multiLevelFilter)
            }
        }
        DebugLog.write(self)
    }

    public func clearValue(_ value: String, for filterInfo: FilterInfoType) {
        guard let filterKey = filterParameter(for: filterInfo) else {
            return
        }
        removeSelectionValue(value, for: filterKey)

        if let multiLevelFilter = filterInfo as? MultiLevelListSelectionFilterInfo {
            multiLevelFilter.updateSelectionState(self)
            updateSelectionStateForParents(of: multiLevelFilter)
        }

        DebugLog.write(self)
    }

    public func rangeValue(for filterInfo: RangeFilterInfoType) -> RangeValue? {
        guard let filterKey = filterParameter(for: filterInfo) else {
            return nil
        }
        let low = intOrNil(from: selectionValues(for: rangeFilterKeyLow(fromBaseKey: filterKey)).first)
        let high = intOrNil(from: selectionValues(for: rangeFilterKeyHigh(fromBaseKey: filterKey)).first)
        if let low = low, let high = high {
            return .closed(lowValue: low, highValue: high)
        } else if let low = low {
            return .minimum(lowValue: low)
        } else if let high = high {
            return .maximum(highValue: high)
        } else {
            return nil
        }
    }

    public func setValue(_ range: RangeValue, for filterInfo: FilterInfoType) {
        guard let filterKey = filterParameter(for: filterInfo) else {
            return
        }
        setRangeSelectionValue(range, for: filterKey)
        DebugLog.write(self)
    }

    public func stepperValue(for filterInfo: StepperFilterInfoType) -> Int? {
        guard let filterKey = filterParameter(for: filterInfo) else {
            return nil
        }
        let low = intOrNil(from: selectionValues(for: rangeFilterKeyLow(fromBaseKey: filterKey)).first)
        return low
    }
}
