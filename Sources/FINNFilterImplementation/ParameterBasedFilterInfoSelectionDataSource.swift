//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

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

    private let selectionDataSource: FilterSelectionData
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
        selectionDataSource = FilterSelectionData(selectionValues: selectionValues)
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

    private func intOrNil(from value: String?) -> Int? {
        guard let value = value else {
            return nil
        }
        return Int(value)
    }

    private func filterParameter(for filterInfo: FilterInfoType) -> String? {
        if let filter = filterInfo as? ParameterBasedFilterInfo {
            return filter.parameterName
        }
        return nil
    }

    private func rangeFilterKeyLow(fromBaseKey filterKey: String) -> String {
        return filterKey + "_from"
    }

    private func rangeFilterKeyHigh(fromBaseKey filterKey: String) -> String {
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
        guard let filterKey = filterParameter(for: filterInfo) else {
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
        guard let filterKey = filterParameter(for: filterInfo) else {
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
        guard let filterKey = filterParameter(for: filterInfo) else {
            return
        }
        if filterInfo is RangeFilterInfoType {
            selectionDataSource.removeSelectionValues(rangeFilterKeyLow(fromBaseKey: filterKey))
            selectionDataSource.removeSelectionValues(rangeFilterKeyHigh(fromBaseKey: filterKey))
        } else if filterInfo is StepperFilterInfoType {
            selectionDataSource.removeSelectionValues(rangeFilterKeyLow(fromBaseKey: filterKey))
        } else {
            selectionDataSource.removeSelectionValues(filterKey)

            if let multiLevelFilter = filterInfo as? MultiLevelListSelectionFilterInfo {
                multiLevelFilter.selectionState = .none
                selectionDataSource.updateSelectionStateForAncestors(of: multiLevelFilter)
            }
        }
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
            delegate?.parameterBasedFilterInfoSelectionDataSourceDidChange(self)
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
        let low = intOrNil(from: selectionDataSource.selectionValues(for: rangeFilterKeyLow(fromBaseKey: filterKey)).first)
        let high = intOrNil(from: selectionDataSource.selectionValues(for: rangeFilterKeyHigh(fromBaseKey: filterKey)).first)
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
        let lowKey = rangeFilterKeyLow(fromBaseKey: filterKey)
        let highKey = rangeFilterKeyHigh(fromBaseKey: filterKey)
        switch range {
        case let .minimum(lowValue):
            selectionDataSource.setStringValue(lowValue.description, for: lowKey)
            selectionDataSource.removeSelectionValues(highKey)
        case let .maximum(highValue):
            selectionDataSource.removeSelectionValues(lowKey)
            selectionDataSource.setStringValue(highValue.description, for: highKey)
        case let .closed(lowValue, highValue):
            selectionDataSource.setStringValue(lowValue.description, for: lowKey)
            selectionDataSource.setStringValue(highValue.description, for: highKey)
        }
        delegate?.parameterBasedFilterInfoSelectionDataSourceDidChange(self)
    }

    public func stepperValue(for filterInfo: StepperFilterInfoType) -> Int? {
        guard let filterKey = filterParameter(for: filterInfo) else {
            return nil
        }
        let low = intOrNil(from: selectionDataSource.selectionValues(for: rangeFilterKeyLow(fromBaseKey: filterKey)).first)
        return low
    }

    public func setValue(latitude: Double, longitude: Double, radius: Int, locationName: String?, for filterInfo: FilterInfoType) {
        if let filterKey = filterParameter(for: filterInfo) {
            selectionDataSource.removeSelectionValues(filterKey)
        }
        selectionDataSource.setStringValue(latitude.description, for: GeoKey.latitude)
        selectionDataSource.setStringValue(longitude.description, for: GeoKey.longitude)
        selectionDataSource.setStringValue(radius.description, for: GeoKey.radius)
        if let locationName = locationName {
            selectionDataSource.setStringValue(locationName, for: GeoKey.locationName)
        } else {
            selectionDataSource.removeSelectionValues(GeoKey.locationName)
        }
        delegate?.parameterBasedFilterInfoSelectionDataSourceDidChange(self)
    }

    public func setValue(geoFilterValue: GeoFilterValue, for filterInfo: FilterInfoType) {
        setValue(latitude: geoFilterValue.latitude, longitude: geoFilterValue.longitude, radius: geoFilterValue.radius, locationName: geoFilterValue.locationName, for: filterInfo)
    }

    public func geoValue() -> GeoFilterValue? {
        guard let latitudeStr = selectionDataSource.selectionValues[GeoKey.latitude]?.first,
            let longitudeStr = selectionDataSource.selectionValues[GeoKey.longitude]?.first,
            let radiusStr = selectionDataSource.selectionValues[GeoKey.radius]?.first else {
            return nil
        }
        guard let latitude = Double(latitudeStr), let longitude = Double(longitudeStr), let radius = Int(radiusStr) else {
            return nil
        }
        let locationName = selectionDataSource.selectionValues[GeoKey.locationName]?.first
        return GeoFilterValue(latitude: latitude, longitude: longitude, radius: radius, locationName: locationName)
    }
}
