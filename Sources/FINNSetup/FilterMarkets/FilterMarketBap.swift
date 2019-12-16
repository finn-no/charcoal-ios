//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public enum FilterMarketBap: String, CaseIterable {
    case bap
}

// MARK: - FilterConfiguration

extension FilterMarketBap: FilterConfiguration {
    public var preferenceFilterKeys: [FilterKey] {
        return [.searchType, .segment, .condition, .published]
    }

    public var rootLevelFilterKeys: [FilterKey] {
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
            .map,
            .location,
            .price,
            .christmas,
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

    public func rangeConfiguration(forKey key: FilterKey) -> RangeFilterConfiguration? {
        switch key {
        case .horseHeight:
            return .configuration(minimumValue: 120, maximumValue: 200, increment: 10, unit: .centimeters)
        case .lengthCm:
            return .configuration(minimumValue: 50, maximumValue: 220, increment: 10, unit: .centimeters)
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
                unit: .currency,
                usesSmallNumberInputFont: false
            )
        default:
            return nil
        }
    }

    public func stepperConfiguration(forKey key: FilterKey) -> StepperFilterConfiguration? {
        return nil
    }
}
