//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

class FINNFilterSelectionData: NSObject {
    private struct GeoKey {
        static let latitude = "lat"
        static let longitude = "lon"
        static let radius = "radius"
        static let locationName = "geoLocationName"
    }

    private(set) var selectionValues: [String: [String]]

    init(selectionValues: [String: [String]]) {
        self.selectionValues = selectionValues
    }

    convenience override init() {
        self.init(selectionValues: [:])
    }
}

extension FINNFilterSelectionData {
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

    func setGeoLocation(latitude: Double, longitude: Double, radius: Int, locationName: String?) {
        setStringValue(latitude.description, for: GeoKey.latitude)
        setStringValue(longitude.description, for: GeoKey.longitude)
        setStringValue(radius.description, for: GeoKey.radius)
        if let locationName = locationName {
            setStringValue(locationName, for: GeoKey.locationName)
        } else {
            removeSelectionValues(GeoKey.locationName)
        }
    }

    func geoLocation() -> GeoFilterValue? {
        guard let latitudeStr = selectionValues[GeoKey.latitude]?.first,
            let longitudeStr = selectionValues[GeoKey.longitude]?.first,
            let radiusStr = selectionValues[GeoKey.radius]?.first else {
            return nil
        }
        guard let latitude = Double(latitudeStr), let longitude = Double(longitudeStr), let radius = Int(radiusStr) else {
            return nil
        }
        let locationName = selectionValues[GeoKey.locationName]?.first
        return GeoFilterValue(latitude: latitude, longitude: longitude, radius: radius, locationName: locationName)
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
                removeValue(parent.value, for: parent)
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
                removeSelectionValue(childFilter.value, for: filterKey)
            }
        }

        if let multiLevelFilter = filterInfo as? MultiLevelListSelectionFilterInfo {
            multiLevelFilter.selectionState = .none
            removeValue(multiLevelFilter.value, for: multiLevelFilter)

            if updateSelectionStateForParent {
                updateSelectionStateForAncestors(of: multiLevelFilter)
            }
        }
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

    func addValue(_ value: String, for filterInfo: FilterInfoType) {
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
    }

    func clearAll(for filterInfo: FilterInfoType) {
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
    }
}
