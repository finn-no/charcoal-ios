//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol ParameterBasedFilterInfoSelectionDataSourceDelegate: AnyObject {
    func parameterBasedFilterInfoSelectionDataSourceDidChange(_: ParameterBasedFilterInfoSelectionDataSource)
}

public class ParameterBasedFilterInfoSelectionDataSource: NSObject {
    private let selectionDataSource: FINNFilterSelectionData
    public var selectionValues: [String: [String]] {
        return selectionDataSource.selectionValues
    }

    var multiLevelFilterLookup: [FilterValueUniqueKey: FilterValueWithNumberOfHitsType] = [:]
    public weak var delegate: ParameterBasedFilterInfoSelectionDataSourceDelegate?

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
        selectionDataSource = FINNFilterSelectionData(selectionValues: selectionValues)
    }

    public convenience override init() {
        self.init(queryItems: [URLQueryItem]())
    }

    public override var description: String {
        return selectionAsQueryString
    }

    public var selectionAsQueryString: String {
        return selectionValues.compactMap({ (keyAndValues) -> String? in
            return keyAndValues.value.map({ keyAndValues.key + "=" + $0 })
                .joined(separator: "&")
        }).joined(separator: "&")
    }

    public var selectionAsQueryItems: [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        selectionValues.forEach({ keyAndValues in
            queryItems.append(contentsOf: keyAndValues.value.map({ URLQueryItem(name: keyAndValues.key, value: $0) }))
        })
        return queryItems
    }

    func updateSelectionStateForFilter(_ filter: MultiLevelListSelectionFilterInfo) {
        if let childrenSelectionState = filter.selectionStateOfChildren(), childrenSelectionState != .none {
            filter.selectionState = childrenSelectionState
        } else {
            if let filterSelectionValue = value(for: filter), filterSelectionValue.contains(filter.value) {
                filter.selectionState = .selected
            }
        }
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
                    if let selectedFilterInfo = multiLevelFilterLookup[FilterValueUniqueKey(parameterName: selectionValuesAndKey.key, value: selectionValue)] as? MultiLevelListSelectionFilterInfo {
                        guard selectedFilterInfo.selectionState == .selected else {
                            return
                        }
                        if let parent = selectedFilterInfo.parent as? MultiLevelListSelectionFilterInfo, parent.selectionState == .selected {
                            return
                        }
                        if selectedFilterInfo === multiLevelFilterInfo || selectionDataSource.isAncestor(multiLevelFilterInfo, to: selectedFilterInfo) {
                            values.append(FilterSelectionDataInfo(filter: selectedFilterInfo, value: selectedFilterInfo.value))
                        }
                    }
                })
            }

            return values
        } else if let rangeFilterInfo = filterInfo as? RangeFilterInfo, let value = rangeValue(for: rangeFilterInfo) {
            return [FilterRangeSelectionInfo(filter: rangeFilterInfo, value: value)]
        } else if let stepperFilterInfo = filterInfo as? StepperFilterInfo, let value = stepperValue(for: stepperFilterInfo) {
            return [FilterStepperSelectionInfo(filter: stepperFilterInfo, value: value)]
        } else if let rootValues = value(for: filterInfo) {
            return rootValues.map({ FilterSelectionDataInfo(filter: filterInfo, value: $0) })
        }
        return []
    }

    public func value(for filterInfo: FilterInfoType) -> [String]? {
        guard let filterKey = selectionDataSource.filterParameter(for: filterInfo) else {
            return nil
        }
        if filterInfo is RangeFilterInfoType {
        } else {
            let values = selectionDataSource.selectionValues(for: filterKey)

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
        guard let filterKey = selectionDataSource.filterParameter(for: filterInfo) else {
            return
        }

        if let filterSelectionValue = filterSelectionValue {
            selectionDataSource.setSelectionValues(filterSelectionValue, for: filterKey)
        } else {
            selectionDataSource.removeSelectionValues(filterKey)
        }

        if let multiLevelFilter = filterInfo as? MultiLevelListSelectionFilterInfo {
            if let parent = multiLevelFilter.parent as? MultiLevelListSelectionFilterInfo, parent.hasParent, parent.selectionState == .none {
                addValue(parent.value, for: parent)
            }
            multiLevelFilter.selectionState = .selected
            selectionDataSource.updateSelectionStateForAncestors(of: multiLevelFilter)
        }
        delegate?.parameterBasedFilterInfoSelectionDataSourceDidChange(self)
    }

    public func addValue(_ value: String, for filterInfo: FilterInfoType) {
        selectionDataSource.addValue(value, for: filterInfo)
        delegate?.parameterBasedFilterInfoSelectionDataSourceDidChange(self)
    }

    public func clearAll(for filterInfo: FilterInfoType) {
        selectionDataSource.clearAll(for: filterInfo)
        delegate?.parameterBasedFilterInfoSelectionDataSourceDidChange(self)
    }

    public func clearValue(_ value: String, for filterInfo: FilterInfoType) {
        selectionDataSource.removeValue(value, for: filterInfo)
        delegate?.parameterBasedFilterInfoSelectionDataSourceDidChange(self)
    }

    public func clearValueAndValueForChildren(for filterInfo: MultiLevelListSelectionFilterInfoType) {
        selectionDataSource.removeValueAndValueForChildren(for: filterInfo, updateSelectionStateForParent: true)
        delegate?.parameterBasedFilterInfoSelectionDataSourceDidChange(self)
    }

    public func setValueAndClearValueForChildren(_ value: String?, for filterInfo: MultiLevelListSelectionFilterInfoType) {
        selectionDataSource.removeValueAndValueForChildren(for: filterInfo, updateSelectionStateForParent: true)
        if let value = value {
            selectionDataSource.addValue(value, for: filterInfo)
        }
        delegate?.parameterBasedFilterInfoSelectionDataSourceDidChange(self)
    }

    public func clearSelection(at selectionValueIndex: Int, in selectionInfo: FilterSelectionInfo) {
        if let selectionData = selectionInfo as? FilterSelectionDataInfo {
            selectionDataSource.removeValue(selectionData.value, for: selectionData.filter)
        } else if let selectionData = selectionInfo as? FilterRangeSelectionInfo {
            selectionDataSource.clearAll(for: selectionData.filter)
        } else if let selectionData = selectionInfo as? FilterStepperSelectionInfo {
            selectionDataSource.clearAll(for: selectionData.filter)
        }
        delegate?.parameterBasedFilterInfoSelectionDataSourceDidChange(self)
    }

    public func rangeValue(for filterInfo: RangeFilterInfoType) -> RangeValue? {
        guard let filterKey = selectionDataSource.filterParameter(for: filterInfo) else {
            return nil
        }
        let low = selectionDataSource.intOrNil(from: selectionDataSource.selectionValues(for: selectionDataSource.rangeFilterKeyLow(fromBaseKey: filterKey)).first)
        let high = selectionDataSource.intOrNil(from: selectionDataSource.selectionValues(for: selectionDataSource.rangeFilterKeyHigh(fromBaseKey: filterKey)).first)
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
        guard let filterKey = selectionDataSource.filterParameter(for: filterInfo) else {
            return
        }
        selectionDataSource.setRangeSelectionValue(range, for: filterKey)
        delegate?.parameterBasedFilterInfoSelectionDataSourceDidChange(self)
    }

    public func stepperValue(for filterInfo: StepperFilterInfoType) -> Int? {
        guard let filterKey = selectionDataSource.filterParameter(for: filterInfo) else {
            return nil
        }
        let low = selectionDataSource.intOrNil(from: selectionDataSource.selectionValues(for: selectionDataSource.rangeFilterKeyLow(fromBaseKey: filterKey)).first)
        return low
    }

    public func setValue(latitude: Double, longitude: Double, radius: Int, locationName: String?, for filterInfo: FilterInfoType) {
        selectionDataSource.clearAll(for: filterInfo)
        selectionDataSource.setGeoLocation(latitude: latitude, longitude: longitude, radius: radius, locationName: locationName)
        delegate?.parameterBasedFilterInfoSelectionDataSourceDidChange(self)
    }

    public func setValue(geoFilterValue: GeoFilterValue, for filterInfo: FilterInfoType) {
        selectionDataSource.clearAll(for: filterInfo)
        selectionDataSource.setGeoLocation(latitude: geoFilterValue.latitude, longitude: geoFilterValue.longitude, radius: geoFilterValue.radius, locationName: geoFilterValue.locationName)
        delegate?.parameterBasedFilterInfoSelectionDataSourceDidChange(self)
    }

    public func geoValue(for filterInfo: FilterInfoType) -> GeoFilterValue? {
        return selectionDataSource.geoLocation()
    }
}
