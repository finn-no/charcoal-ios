//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterSelectionInfo {
}

public struct FilterSelectionDataInfo: FilterSelectionInfo {
    public let filter: FilterInfoType
    public let value: [String]
}

public struct FilterRangeSelectionInfo: FilterSelectionInfo {
    public let filter: RangeFilterInfoType
    public let value: RangeValue
}

public enum RangeValue {
    case minimum(lowValue: Int)
    case maximum(highValue: Int)
    case closed(lowValue: Int, highValue: Int)
}

public enum MultiLevelListItemSelectionState {
    case none
    case partial
    case selected
}

public protocol FilterSelectionDataSource: AnyObject {
    func selectionState(_ filterInfo: MultiLevelListSelectionFilterInfoType) -> MultiLevelListItemSelectionState
    func value(for filterInfo: FilterInfoType) -> [String]?
    func valueAndSubLevelValues(for filterInfo: FilterInfoType) -> [FilterSelectionInfo]
    func setValue(_ filterSelectionValue: [String]?, for filterInfo: FilterInfoType)
    func addValue(_ value: String, for filterInfo: FilterInfoType)
    func clearAll(for filterInfo: FilterInfoType)
    func clearValue(_ value: String, for filterInfo: FilterInfoType)

    func rangeValue(for filterInfo: RangeFilterInfoType) -> RangeValue?
    func setValue(_ range: RangeValue, for filterInfo: RangeFilterInfoType)
}
