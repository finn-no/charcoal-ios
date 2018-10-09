//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class ParameterBasedFilterInfoSelectionDataSource: NSObject {
    private var selectionValues: [String: [String]]
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

    func removeSelectionValue(_ key: String) {
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

    func setStringValue(_ value: String?, for key: String) {
        if let value = value, !value.isEmpty {
            setSelectionValue(value, for: key)
        } else {
            removeSelectionValue(key)
        }
    }

    func setFilterSelectionValue(_ value: FilterSelectionValue, for key: String) {
        switch value {
        case let .singleSelection(value):
            setStringValue(value, for: key)
        case let .multipleSelection(values):
            setSelectionValues(values, for: key)
        case let .rangeSelection(range):
            switch range {
            case let .minimum(lowValue):
                setStringValue(lowValue.description, for: key + "_from")
                removeSelectionValue(key + "_to")
            case let .maximum(highValue):
                removeSelectionValue(key + "_from")
                setStringValue(highValue.description, for: key + "_to")
            case let .closed(lowValue, highValue):
                setStringValue(lowValue.description, for: key + "_from")
                setStringValue(highValue.description, for: key + "_to")
            }
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
}

extension ParameterBasedFilterInfoSelectionDataSource: FilterSelectionDataSource {
    public func valueAndSubLevelValues(for filterInfo: FilterInfoType) -> [FilterSelectionData] {
        if let multiLevelFilterInfo = filterInfo as? MultiLevelListSelectionFilterInfo {
            guard multiLevelFilterInfo.selectionState != .none else {
                return []
            }
            var values = [FilterSelectionData]()

            selectionValues.forEach { selectionValuesAndKey in
                selectionValuesAndKey.value.forEach({ selectionValue in
                    if let selectedFilterInfo = multiLevelFilterLookup[MultiLevelListSelectionFilterInfo.LookupKey(parameterName: selectionValuesAndKey.key, value: selectionValue)] {
                        if selectedFilterInfo === multiLevelFilterInfo || isAncestor(multiLevelFilterInfo, to: selectedFilterInfo.parent) {
                            if let selectionValueEhhh = value(for: selectedFilterInfo) {
                                values.append(FilterSelectionData(filter: multiLevelFilterInfo, value: selectionValueEhhh))
                            }
                        }
                    }
                })
            }

            return values
        } else if let rootValue = value(for: filterInfo) {
            return [FilterSelectionData(filter: filterInfo, value: rootValue)]
        }
        return []
    }

    public func value(for filterInfo: FilterInfoType) -> FilterSelectionValue? {
        guard let filterKey = filterParameter(for: filterInfo) else {
            return nil
        }
        if filterInfo is RangeFilterInfoType {
            let low = intOrNil(from: selectionValues(for: filterKey + "_from").first)
            let high = intOrNil(from: selectionValues(for: filterKey + "_to").first)
            if let low = low, let high = high {
                return .rangeSelection(range: .closed(lowValue: low, highValue: high))
            } else if let low = low {
                return .rangeSelection(range: .minimum(lowValue: low))
            } else if let high = high {
                return .rangeSelection(range: .maximum(highValue: high))
            } else {
                return nil
            }
        } else {
            let values = selectionValues(for: filterKey)

            /* if let multiLevelFilterInfo = filterInfo as? MultiLevelListSelectionFilterInfo {
             let isCurrentFilterValueSelected = values.contains(multiLevelFilterInfo.value)
             if !isCurrentFilterValueSelected {
             return nil
             }
             } */

            if values.count < 1 {
                return nil
            }
            if values.count > 1 {
                return .multipleSelection(values: values)
            } else {
                if let value = values.first {
                    return .singleSelection(value: value)
                }
            }
            return nil
        }
    }

    public func setValue(_ filterSelectionValue: FilterSelectionValue?, for filterInfo: FilterInfoType) {
        guard let filterKey = filterParameter(for: filterInfo) else {
            return
        }
        if let filterSelectionValue = filterSelectionValue {
            setFilterSelectionValue(filterSelectionValue, for: filterKey)
        } else {
            removeSelectionValue(filterKey)
        }

        if let multiLevelFilter = filterInfo as? MultiLevelListSelectionFilterInfo {
            multiLevelFilter.updateSelectionState(self)
            updateSelectionStateForParents(of: multiLevelFilter)
        }

        DebugLog.write(self)
    }
}
