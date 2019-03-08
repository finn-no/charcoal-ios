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

    public func rangeConfiguration(forKey key: String) -> RangeFilterConfiguration? {
        guard let filterKey = FilterKey(stringValue: key) else {
            return nil
        }

        switch filterKey {
        case .horseHeight:
            return RangeFilterConfiguration(
                minimumValue: 120,
                maximumValue: 200,
                valueKind: .incremented(10),
                hasLowerBoundOffset: true,
                hasUpperBoundOffset: true,
                unit: "cm",
                accessibilityValueSuffix: nil,
                usesSmallNumberInputFont: false,
                displaysUnitInNumberInput: true,
                isCurrencyValueRange: false
            )
        case .lengthCm:
            return RangeFilterConfiguration(
                minimumValue: 50,
                maximumValue: 220,
                valueKind: .incremented(10),
                hasLowerBoundOffset: true,
                hasUpperBoundOffset: true,
                unit: "cm",
                accessibilityValueSuffix: nil,
                usesSmallNumberInputFont: false,
                displaysUnitInNumberInput: true,
                isCurrencyValueRange: false
            )
        case .price:
            return RangeFilterConfiguration(
                minimumValue: 0,
                maximumValue: 30000,
                valueKind: .intervals(
                    array: [
                        (from: 0, increment: 50),
                        (from: 500, increment: 100),
                        (from: 1500, increment: 500),
                        (from: 6000, increment: 1000),
                    ]
                ),
                hasLowerBoundOffset: false,
                hasUpperBoundOffset: true,
                unit: "kr",
                accessibilityValueSuffix: nil,
                usesSmallNumberInputFont: false,
                displaysUnitInNumberInput: true,
                isCurrencyValueRange: true
            )
        default:
            return nil
        }
    }

    public func stepperConfiguration(forKey key: String) -> StepperFilterConfiguration? {
        return nil
    }
}
