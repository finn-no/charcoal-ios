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
        case .price:
            return RangeFilterConfiguration(
                minimumValue: 0,
                maximumValue: 30000,
                valueKind: .incremented(1000),
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
