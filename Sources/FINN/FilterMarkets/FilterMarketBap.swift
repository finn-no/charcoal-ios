//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public enum FilterMarketBap: String, CaseIterable {
    case bap
}

// MARK: - FilterConfiguration

extension FilterMarketBap: FilterConfiguration {
    public func viewModel(forKey key: String) -> RangeFilterInfo? {
        return createFilterInfoFrom(key: key)
    }

    public func handlesVerticalId(_ vertical: String) -> Bool {
        return rawValue == vertical || vertical.hasPrefix(rawValue + "-")
    }

    public var preferenceFilterKeys: [FilterKey] {
        return [.searchType, .segment, .condition, .published]
    }

    public var supportedFiltersKeys: [FilterKey] {
        return [
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
            .price,
        ]
    }

    public var contextFilters: Set<FilterKey> {
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

    public var mapFilterKey: FilterKey? {
        return .location
    }

    private func createFilterInfoFrom(key: String) -> RangeFilterInfo? {
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
