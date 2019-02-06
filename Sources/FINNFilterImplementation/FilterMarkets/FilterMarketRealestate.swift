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

extension FilterMarketRealestate: CCFilterConfiguration {
    public func viewController(for filterNode: CCFilterNode) -> CCViewController? {
        return nil
    }
}

// MARK: - FilterConfiguration

extension FilterMarketRealestate: FilterConfiguration {
    func handlesVerticalId(_ vertical: String) -> Bool {
        return rawValue == vertical
    }

    var preferenceFilterKeys: [FilterKey] {
        let defaultFilter: [FilterKey] = [.published]
        switch self {
        case .homes:
            return defaultFilter + [.isSold, .isNewProperty, .isPrivateBroker]
        default: return defaultFilter
        }
    }

    var supportedFiltersKeys: [FilterKey] {
        switch self {
        case .homes:
            return [
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
                .location,
                .price,
                .plotArea,
            ]
        case .leisureSale:
            return [
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
                .location,
                .propertyType,
                .price,
                .noOfOccupants,
                .rentFrom,
            ]
        case .businessSale:
            return [
                .location,
                .price,
                .area,
                .propertyType,
            ]
        case .businessLetting:
            return [
                .location,
                .area,
                .propertyType,
            ]
        case .businessPlot:
            return [
                .location,
                .price,
                .plotArea,
            ]
        case .companyForSale:
            return [
                .location,
                .category,
            ]
        case .travelFhh:
            return []
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
            return StepperFilterInfo(unit: "soverom", steps: 1, lowerLimit: 0, upperLimit: 6, title: rangeFilterData.title, parameterName: rangeFilterData.parameterName)
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
