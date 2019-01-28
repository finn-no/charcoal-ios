//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

enum FilterMarketCar: String, CaseIterable {
    case norway = "car-norway"
    case abroad = "car-abroad"
    case mobileHome = "mobile-home"
    case caravan
}

// MARK: - FilterConfiguration

extension FilterMarketCar: FilterConfiguration {
    func handlesVerticalId(_ vertical: String) -> Bool {
        return rawValue == vertical
    }

    var preferenceFilterKeys: [FilterKey] {
        switch self {
        case .norway, .abroad:
            return [.published, .priceChanged, .dealerSegment]
        case .mobileHome, .caravan:
            return [.published, .caravanDealerSegment]
        }
    }

    var supportedFiltersKeys: [FilterKey] {
        switch self {
        case .norway:
            return [
                .make,
                .salesForm,
                .year,
                .mileage,
                .price,
                .location,
                .bodyType,
                .engineFuel,
                .exteriorColour,
                .engineEffect,
                .numberOfSeats,
                .wheelDrive,
                .transmission,
                .carEquipment,
                .wheelSets,
                .warrantyInsurance,
                .condition,
                .registrationClass,
            ]
        case .abroad:
            return [
                .make,
                .salesForm,
                .year,
                .mileage,
                .leasepriceInit,
                .leasepriceMonth,
                .price,
                .location,
                .bodyType,
                .engineFuel,
                .exteriorColour,
                .engineEffect,
                .numberOfSeats,
                .wheelDrive,
                .transmission,
                .carEquipment,
                .wheelSets,
                .warrantyInsurance,
                .condition,
                .registrationClass,
            ]
        case .mobileHome:
            return [
                .make,
                .salesForm,
                .year,
                .mileage,
                .price,
                .location,
                .noOfSleepers,
                .numberOfSeats,
                .engineEffect,
                .mobileHomeSegment,
                .transmission,
                .wheelDrive,
                .length,
                .weight,
            ]
        case .caravan:
            return [
                .make,
                .salesForm,
                .year,
                .mileage,
                .price,
                .location,
                .noOfSleepers,
                .caravanSegment,
                .length,
                .width,
                .weight,
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
        case .year:
            lowValue = 1950
            highValue = Calendar.current.component(.year, from: Date())
            unit = "år"
            rangeBoundsOffsets = (hasLowerBoundOffset: true, hasUpperBoundOffset: true)
            increment = 1
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: false, isCurrencyValueRange: false)
        case .engineEffect:
            lowValue = 0
            highValue = 500
            unit = "hk"
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            increment = 10
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .mileage:
            lowValue = 0
            highValue = 200_000
            unit = "km"
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            increment = 1000
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .numberOfSeats:
            lowValue = 0
            highValue = 10
            unit = "seter"
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            increment = 1
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .price:
            lowValue = 0
            highValue = 500_000
            unit = "kr"
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            increment = 1000
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: true)
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
