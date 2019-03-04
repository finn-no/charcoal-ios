//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public enum FilterMarketBap: String, CaseIterable {
    case bap
}

// MARK: - FilterConfiguration

extension FilterMarketBap: FINNFilterConfiguration {
    public var preferenceFilterKeys: [FilterKey] {
        return [.searchType, .segment, .condition, .published]
    }

    public var rootLevelFilterKeys: [FilterKey] {
        return [
            .query,
            .preferences,
            .category,
            .bikesType,
            .carPartsBrand,
            .carTiresAndRimsType,
            .clothingSize,
            .childrenClothingSize,
            .computerAccType,
            .forRent,
            .guitarType,
            .hifiPartsType,
            .horseHeight,
            .laptopsBrand,
            .mobileBrand,
            .shoeSize,
            .womenClothingBrand,
            .lengthCm,
            .location,
            .map,
            .price,
        ]
    }

    public var contextFilterKeys: Set<FilterKey> {
        return [
            .bikesType,
            .carPartsBrand,
            .carTiresAndRimsType,
            .clothingSize,
            .childrenClothingSize,
            .computerAccType,
            .forRent,
            .guitarType,
            .hifiPartsType,
            .horseHeight,
            .laptopsBrand,
            .mobileBrand,
            .shoeSize,
            .womenClothingBrand,
            .lengthCm,
        ]
    }

    public var mutuallyExclusiveFilterKeys: Set<FilterKey> {
        return [.location, .map]
    }

    public func handlesVerticalId(_ vertical: String) -> Bool {
        return rawValue == vertical || vertical.hasPrefix(rawValue + "-")
    }

    public func rangeViewModel(forKey key: String) -> RangeFilterInfo? {
        let lowValue: Int
        let highValue: Int
        let increment: Int
        let unit: String
        let rangeBoundsOffsets: RangeFilterInfo.RangeBoundsOffsets
        let accessibilityValues: RangeFilterInfo.AccessibilityValues
        let appearanceProperties: RangeFilterInfo.AppearenceProperties

        guard let filterKey = FilterKey(stringValue: key) else {
            return nil
        }
        switch filterKey {
        case .price:
            lowValue = 0
            highValue = 30000
            unit = "kr"
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            increment = 1000
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: true)
        default:
            return nil
        }

        return RangeFilterInfo(
            kind: .slider,
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
