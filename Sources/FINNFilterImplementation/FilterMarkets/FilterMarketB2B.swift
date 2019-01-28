//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

enum FilterMarketB2B: String, CaseIterable {
    case truck
    case truckAbroad = "truck-abroad"
    case bus
    case construction
    case agricultureTractor = "agriculture-tractor"
    case agricultureThresher = "agriculture-thresher"
    case agricultureTools = "agriculture-tools"
    case vanNorway = "van-norway"
    case vanAbroad = "van-abroad"
}

// MARK: - FilterConfiguration

extension FilterMarketB2B: FilterConfiguration {
    func handlesVerticalId(_ vertical: String) -> Bool {
        return rawValue == vertical
    }

    var preferenceFilterKeys: [FilterKey] {
        return [.published]
    }

    var supportedFiltersKeys: [FilterKey] {
        switch self {
        case .truck, .truckAbroad:
            return [
            ]
        case .bus:
            return [
            ]
        case .construction:
            return [
            ]
        case .agricultureTractor, .agricultureThresher:
            return [
            ]
        case .agricultureTools:
            return [
            ]
        case .vanNorway, .vanAbroad:
            return [
            ]
        }
    }

    var mapFilterKey: FilterKey? {
        return .location
    }

    func createFilterInfoFrom(rangeFilterData: FilterData) -> FilterInfoType? {
        let parameterName = rangeFilterData.parameterName
        let name = rangeFilterData.title
        let lowValue: Int
        let highValue: Int
        let increment: Int
        let unit: String
        let rangeBoundsOffsets: RangeFilterInfo.RangeBoundsOffsets
        let accessibilityValues: RangeFilterInfo.AccessibilityValues
        let appearanceProperties: RangeFilterInfo.AppearenceProperties

        guard let filterKey = FilterKey(stringValue: rangeFilterData.parameterName) else {
            return nil
        }

        switch filterKey {
        default:
            return nil
        }

        return RangeFilterInfo(
            parameterName: parameterName,
            title: name,
            lowValue: lowValue,
            highValue: highValue,
            increment: increment,
            rangeBoundsOffsets: rangeBoundsOffsets,
            unit: unit,
            accesibilityValues: accessibilityValues,
            appearanceProperties: appearanceProperties
        )
    }
}
