//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation
import MapKit

public protocol ParameterBasedFilterInfoSelectionDataSourceDelegate: AnyObject {
    func parameterBasedFilterInfoSelectionDataSourceDidChange(_: ParameterBasedFilterInfoSelectionDataSource)
}

public class ParameterBasedFilterInfoSelectionDataSource: NSObject {
    private struct GeoKey {
        static let latitude = "lat"
        static let longitude = "lon"
        static let radius = "radius"
        static let locationName = "geoLocationName"
    }

    public private(set) var selectionValues: [String: [String]]
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
        self.selectionValues = selectionValues
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

private extension ParameterBasedFilterInfoSelectionDataSource {
    func setSelectionValues(_ values: [String], for key: String, callDelegate: Bool = true) {
        selectionValues[key] = values
        if callDelegate {
            delegate?.parameterBasedFilterInfoSelectionDataSourceDidChange(self)
        }
    }

    func setSelectionValue(_ value: String, for key: String, callDelegate: Bool = true) {
        setSelectionValues([value], for: key, callDelegate: callDelegate)
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

    func removeSelectionValue(_ value: String, for key: String, callDelegate: Bool = true) {
        if let previousValues = selectionValues[key] {
            setSelectionValues(previousValues.filter({ $0 != value }), for: key, callDelegate: callDelegate)
        }
    }

    func removeSelectionValues(_ key: String, callDelegate: Bool = true) {
        selectionValues.removeValue(forKey: key)
        if callDelegate {
            delegate?.parameterBasedFilterInfoSelectionDataSourceDidChange(self)
        }
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

    func setStringValue(_ value: String, for key: String, callDelegate: Bool = true) {
        setSelectionValue(value, for: key, callDelegate: callDelegate)
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

    func setGeoLocation(latitude: Double, longitude: Double, radius: Int, locationName: String?) {
        setStringValue(latitude.description, for: GeoKey.latitude, callDelegate: false)
        setStringValue(longitude.description, for: GeoKey.longitude, callDelegate: false)
        setStringValue(radius.description, for: GeoKey.radius, callDelegate: false)
        if let locationName = locationName {
            setStringValue(locationName, for: GeoKey.locationName, callDelegate: true)
        } else {
            removeSelectionValues(GeoKey.locationName, callDelegate: true)
        }
    }

    func geoLocation() -> (latitude: Double, longitude: Double, radius: Int, locationName: String?)? {
        guard let latitudeStr = selectionValues[GeoKey.latitude]?.first,
            let longitudeStr = selectionValues[GeoKey.longitude]?.first,
            let radiusStr = selectionValues[GeoKey.radius]?.first else {
            return nil
        }
        guard let latitude = Double(latitudeStr), let longitude = Double(longitudeStr), let radius = Int(radiusStr) else {
            return nil
        }
        let locationName = selectionValues[GeoKey.locationName]?.first
        return (latitude, longitude, radius, locationName)
    }

    func intOrNil(from value: String?) -> Int? {
        guard let value = value else {
            return nil
        }
        return Int(value)
    }

    func updateSelectionStateForAncestors(of multiLevelFilter: MultiLevelListSelectionFilterInfo) {
        guard let parent = multiLevelFilter.parent as? MultiLevelListSelectionFilterInfo else {
            return
        }
        if let selectionStateOfChildren = parent.selectionStateOfChildren() {
            parent.selectionState = selectionStateOfChildren
            if selectionStateOfChildren == .none {
                clearValue(parent.value, for: parent)
            }
        }
        updateSelectionStateForAncestors(of: parent)
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

    func removeValueAndValueForChildren(for filterInfo: MultiLevelListSelectionFilterInfoType, updateSelectionStateForParent: Bool) {
        for childFilter in filterInfo.filters {
            removeValueAndValueForChildren(for: childFilter, updateSelectionStateForParent: false)
            if let filterKey = filterParameter(for: childFilter) {
                removeSelectionValue(childFilter.value, for: filterKey, callDelegate: false)
            }
        }

        if let multiLevelFilter = filterInfo as? MultiLevelListSelectionFilterInfo {
            multiLevelFilter.selectionState = .none
            removeValue(multiLevelFilter.value, for: multiLevelFilter)

            if updateSelectionStateForParent {
                updateSelectionStateForAncestors(of: multiLevelFilter)
            }
        }
        delegate?.parameterBasedFilterInfoSelectionDataSourceDidChange(self)
    }

    func removeValue(_ value: String, for filterInfo: FilterInfoType) {
        guard let filterKey = filterParameter(for: filterInfo) else {
            return
        }
        removeSelectionValue(value, for: filterKey)

        if let multiLevelFilter = filterInfo as? MultiLevelListSelectionFilterInfo {
            multiLevelFilter.selectionState = .none
            if let selectionStateOfChildren = multiLevelFilter.selectionStateOfChildren() {
                multiLevelFilter.selectionState = selectionStateOfChildren
            }

            updateSelectionStateForAncestors(of: multiLevelFilter)
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
                        if selectedFilterInfo === multiLevelFilterInfo || isAncestor(multiLevelFilterInfo, to: selectedFilterInfo) {
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
            if let parent = multiLevelFilter.parent as? MultiLevelListSelectionFilterInfo, parent.hasParent, parent.selectionState == .none {
                addValue(parent.value, for: parent)
            }
            multiLevelFilter.selectionState = .selected
            updateSelectionStateForAncestors(of: multiLevelFilter)
        }

        DebugLog.write(self)
    }

    public func addValue(_ value: String, for filterInfo: FilterInfoType) {
        guard let filterKey = filterParameter(for: filterInfo) else {
            return
        }
        addSelectionValue(value, for: filterKey)

        if let multiLevelFilter = filterInfo as? MultiLevelListSelectionFilterInfo {
            multiLevelFilter.selectionState = .selected
            if let parent = multiLevelFilter.parent as? MultiLevelListSelectionFilterInfo, parent.hasParent, parent.selectionState == .none {
                addValue(parent.value, for: parent)
            }
            updateSelectionStateForAncestors(of: multiLevelFilter)
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
                multiLevelFilter.selectionState = .none
                updateSelectionStateForAncestors(of: multiLevelFilter)
            }
        }
        DebugLog.write(self)
    }

    public func clearValue(_ value: String, for filterInfo: FilterInfoType) {
        removeValue(value, for: filterInfo)
        DebugLog.write(self)
    }

    public func clearValueAndValueForChildren(for filterInfo: MultiLevelListSelectionFilterInfoType) {
        removeValueAndValueForChildren(for: filterInfo, updateSelectionStateForParent: true)
        DebugLog.write(self)
    }

    public func clearSelection(at selectionValueIndex: Int, in selectionInfo: FilterSelectionInfo) {
        if let selectionData = selectionInfo as? FilterSelectionDataInfo {
            clearValue(selectionData.value, for: selectionData.filter)
        } else if let selectionData = selectionInfo as? FilterRangeSelectionInfo {
            clearAll(for: selectionData.filter)
        } else if let selectionData = selectionInfo as? FilterStepperSelectionInfo {
            clearAll(for: selectionData.filter)
        }
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

    public func setValue(latitude: Double, longitude: Double, radius: Int, locationName: String?, for filterInfo: FilterInfoType) {
        clearAll(for: filterInfo)
        setGeoLocation(latitude: latitude, longitude: longitude, radius: radius, locationName: locationName)
        DebugLog.write(self)
    }

    public func geoValue(for filterInfo: FilterInfoType) -> (latitude: Double, longitude: Double, radius: Int, locationName: String?)? {
        return geoLocation()
    }
}
