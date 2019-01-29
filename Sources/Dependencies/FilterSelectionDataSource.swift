//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterSelectionInfo {
    var isValid: Bool { get }
}

public struct FilterSelectionDataInfo: FilterSelectionInfo {
    public let filter: FilterInfoType
    public let value: String
    public let isValid = true
}

public struct FilterRangeSelectionInfo: FilterSelectionInfo {
    public let filter: RangeFilterInfoType
    public let value: RangeValue

    public var isValid: Bool {
        return filter.sliderInfo.isValidRangeValue(value)
    }
}

public struct FilterStepperSelectionInfo: FilterSelectionInfo {
    public let filter: StepperFilterInfoType
    public let value: Int
    public let isValid = true
}

public enum RangeValue {
    case minimum(lowValue: Int)
    case maximum(highValue: Int)
    case closed(lowValue: Int, highValue: Int)

    static func create(lowValue: Int?, highValue: Int?) -> RangeValue? {
        if let lowValue = lowValue {
            if let highValue = highValue {
                return .closed(lowValue: lowValue, highValue: highValue)
            } else {
                return .minimum(lowValue: lowValue)
            }
        } else if let highValue = highValue {
            return .maximum(highValue: highValue)
        }
        return nil
    }

    var lowValue: Int? {
        switch self {
        case let .minimum(lowValue):
            return lowValue
        case .maximum:
            return nil
        case let .closed(lowValue, _):
            return lowValue
        }
    }

    var highValue: Int? {
        switch self {
        case .minimum:
            return nil
        case let .maximum(highValue):
            return highValue
        case let .closed(_, highValue):
            return highValue
        }
    }
}

public enum MultiLevelListItemSelectionState {
    case none
    case partial
    case selected
}

public struct GeoFilterValue {
    public let latitude: Double
    public let longitude: Double
    public let radius: Int
    public let locationName: String?

    public init(latitude: Double, longitude: Double, radius: Int, locationName: String?) {
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.locationName = locationName
    }
}

public protocol FilterSelectionDataSource: AnyObject {
    func selectionState(_ filterInfo: MultiLevelListSelectionFilterInfoType) -> MultiLevelListItemSelectionState
    func value(for filterInfo: FilterInfoType) -> [String]?
    func valueAndSubLevelValues(for filterInfo: FilterInfoType) -> [FilterSelectionInfo]
    func setValue(_ filterSelectionValue: [String]?, for filterInfo: FilterInfoType)
    func addValue(_ value: String, for filterInfo: FilterInfoType)
    func clearAll(for filterInfo: FilterInfoType)
    func clearValue(_ value: String, for filterInfo: FilterInfoType)
    func setValueAndClearValueForChildren(_ value: String?, for filterInfo: MultiLevelListSelectionFilterInfoType)
    func clearValueAndValueForChildren(for filterInfo: MultiLevelListSelectionFilterInfoType)
    func clearSelection(at selectionValueIndex: Int, in selectionInfo: FilterSelectionInfo)

    func rangeValue(for filterInfo: RangeFilterInfoType) -> RangeValue?
    func setValue(_ range: RangeValue, for filterInfo: FilterInfoType)

    func stepperValue(for filterInfo: StepperFilterInfoType) -> Int?
    func setValue(latitude: Double, longitude: Double, radius: Int, locationName: String?, for filterInfo: FilterInfoType)
    func setValue(geoFilterValue: GeoFilterValue, for filterInfo: FilterInfoType)
    func geoValue() -> GeoFilterValue?
}
