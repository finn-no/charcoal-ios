//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public enum FilterMarketRealestate: String, CaseIterable {
    case homes = "realestate-homes"
    case development = "realestate-development"
    case plot = "realestate-plot"
    case leisureSale = "realestate-leisure-sale"
    case leisureSaleAbroad = "realestate-leisure-sale-abroad"
    case leisurePlot = "realestate-leisure-plot"
    case letting = "realestate-letting"
    case lettingWanted = "realestate-letting-wanted"
    case businessSale = "realestate-business-sale"
    case businessLetting = "realestate-business-letting"
    case businessPlot = "realestate-business-plot"
    case companyForSale = "company-for-sale"
    case travelFhh = "realestate-travel-fhh"
}

// MARK: - FilterConfiguration

extension FilterMarketRealestate: FINNFilterConfiguration {
    public var preferenceFilterKeys: [FilterKey] {
        let defaultFilter: [FilterKey] = [.published]
        switch self {
        case .homes:
            return defaultFilter + [.isSold, .isNewProperty, .isPrivateBroker]
        default: return defaultFilter
        }
    }

    public var rootLevelFilterKeys: [FilterKey] {
        switch self {
        case .homes:
            return [
                .query,
                .preferences,
                .map,
                .location,
                .price,
                .priceCollective,
                .rent,
                .area,
                .noOfBedrooms,
                .constructionYear,
                .propertyType,
                .ownershipType,
                .facilities,
                .viewing,
                .floorNavigator,
                .energyLabel,
                .plotArea,
            ]
        case .development:
            return [
                .query,
                .preferences,
                .map,
                .location,
                .price,
                .priceCollective,
                .area,
                .noOfBedrooms,
                .propertyType,
                .ownershipType,
                .facilities,
                .energyLabel,
            ]
        case .plot, .leisurePlot:
            return [
                .query,
                .preferences,
                .map,
                .location,
                .price,
                .plotArea,
            ]
        case .leisureSale:
            return [
                .query,
                .preferences,
                .map,
                .location,
                .price,
                .area,
                .noOfBedrooms,
                .viewing,
                .leisureSituation,
                .propertyType,
                .facilities,
                .plotOwned,
            ]
        case .leisureSaleAbroad:
            return [
                .query,
                .preferences,
                .map,
                .location,
                .price,
                .area,
                .noOfBedrooms,
                .propertyType,
                .facilities,
                .leisureSituation,
            ]
        case .letting:
            return [
                .query,
                .preferences,
                .map,
                .location,
                .propertyType,
                .price,
                .area,
                .noOfBedrooms,
                .animalsAllowed,
                .furnished,
                .rentFrom,
                .facilities,
                .viewing,
                .floorNavigator,
            ]
        case .lettingWanted:
            return [
                .query,
                .preferences,
                .map,
                .location,
                .propertyType,
                .price,
                .noOfOccupants,
                .rentFrom,
            ]
        case .businessSale:
            return [
                .query,
                .preferences,
                .map,
                .location,
                .price,
                .area,
                .propertyType,
            ]
        case .businessLetting:
            return [
                .query,
                .preferences,
                .map,
                .location,
                .area,
                .propertyType,
            ]
        case .businessPlot:
            return [
                .query,
                .preferences,
                .map,
                .location,
                .price,
                .plotArea,
            ]
        case .companyForSale:
            return [
                .query,
                .preferences,
                .map,
                .location,
                .category,
            ]
        case .travelFhh:
            return []
        }
    }

    public var contextFilterKeys: Set<FilterKey> {
        return []
    }

    public var mutuallyExclusiveFilterKeys: Set<FilterKey> {
        return [.location, .map]
    }

    public func handlesVerticalId(_ vertical: String) -> Bool {
        return rawValue == vertical
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
        case .price, .priceCollective:
            switch self {
            case .plot, .leisurePlot, .businessPlot:
                lowValue = 200_000
                highValue = 1_500_000
                increment = 50000
            case .leisureSale:
                lowValue = 200_000
                highValue = 15_000_000
                increment = 50000
            case .leisureSaleAbroad:
                lowValue = 400_000
                highValue = 10_000_000
                increment = 100_000
            case .letting:
                lowValue = 1000
                highValue = 15000
                increment = 100
            case .lettingWanted:
                lowValue = 4000
                highValue = 15000
                increment = 500
            case .businessSale:
                lowValue = 500_000
                highValue = 7_000_000
                increment = 100_000
            default:
                lowValue = 1_000_000
                highValue = 10_000_000
                increment = 50000
            }
            rangeBoundsOffsets = (hasLowerBoundOffset: true, hasUpperBoundOffset: true)
            unit = "kr"
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: true, displaysUnitInNumberInput: true, isCurrencyValueRange: true)
        case .rent:
            lowValue = 500
            highValue = 20000
            rangeBoundsOffsets = (hasLowerBoundOffset: true, hasUpperBoundOffset: true)
            unit = "kr"
            increment = 500
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: true)
        case .noOfBedrooms:
            lowValue = 0
            highValue = 6
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: false)
            unit = "stk"
            increment = 1
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: true)
            return RangeFilterInfo(
                kind: .stepper,
                lowValue: lowValue,
                highValue: highValue,
                increment: increment,
                rangeBoundsOffsets: rangeBoundsOffsets,
                unit: unit,
                accesibilityValues: accessibilityValues,
                appearanceProperties: appearanceProperties
            )
        case .area:
            switch self {
            case .leisureSaleAbroad:
                lowValue = 50
                highValue = 400
            case .businessSale, .businessLetting:
                lowValue = 50
                highValue = 1500
            default:
                lowValue = 30
                highValue = 400
            }
            rangeBoundsOffsets = (hasLowerBoundOffset: true, hasUpperBoundOffset: true)
            unit = "m\u{00B2}"
            increment = 5
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: true, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .plotArea:
            lowValue = 300
            highValue = 6000
            rangeBoundsOffsets = (hasLowerBoundOffset: true, hasUpperBoundOffset: true)
            unit = "m\u{00B2}"
            increment = 50
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .constructionYear:
            lowValue = 1900
            highValue = Calendar.current.component(.year, from: Date())
            rangeBoundsOffsets = (hasLowerBoundOffset: true, hasUpperBoundOffset: true)
            unit = ""
            increment = 1
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: false, isCurrencyValueRange: false)
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
