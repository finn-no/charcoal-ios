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
                .location,
                .map,
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
                .location,
                .map,
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
                .location,
                .map,
                .price,
                .plotArea,
            ]
        case .leisureSale:
            return [
                .query,
                .preferences,
                .location,
                .map,
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
                .location,
                .map,
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
                .location,
                .map,
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
                .location,
                .map,
                .propertyType,
                .price,
                .noOfOccupants,
                .rentFrom,
            ]
        case .businessSale:
            return [
                .query,
                .preferences,
                .location,
                .map,
                .price,
                .area,
                .propertyType,
            ]
        case .businessLetting:
            return [
                .query,
                .preferences,
                .location,
                .map,
                .area,
                .propertyType,
            ]
        case .businessPlot:
            return [
                .query,
                .preferences,
                .location,
                .map,
                .price,
                .plotArea,
            ]
        case .companyForSale:
            return [
                .query,
                .preferences,
                .location,
                .map,
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

    public func rangeConfiguration(forKey key: String) -> RangeFilterConfiguration? {
        guard let filterKey = FilterKey(stringValue: key) else {
            return nil
        }

        switch filterKey {
        case .price, .priceCollective:
            let minimumValue: Int
            let maximumValue: Int
            let increment: Int

            switch self {
            case .plot, .leisurePlot, .businessPlot:
                minimumValue = 200_000
                maximumValue = 1_500_000
                increment = 50000
            case .leisureSale:
                minimumValue = 200_000
                maximumValue = 15_000_000
                increment = 50000
            case .leisureSaleAbroad:
                minimumValue = 400_000
                maximumValue = 10_000_000
                increment = 100_000
            case .letting:
                minimumValue = 1000
                maximumValue = 15000
                increment = 100
            case .lettingWanted:
                minimumValue = 4000
                maximumValue = 15000
                increment = 500
            case .businessSale:
                minimumValue = 500_000
                maximumValue = 7_000_000
                increment = 100_000
            default:
                minimumValue = 1_000_000
                maximumValue = 10_000_000
                increment = 50000
            }

            return .configuration(
                minimumValue: minimumValue,
                maximumValue: maximumValue,
                increment: increment,
                unit: .currency
            )
        case .rent:
            return .configuration(minimumValue: 500, maximumValue: 20000, increment: 500, unit: .currency)
        case .area:
            let minimumValue: Int
            let maximumValue: Int

            switch self {
            case .leisureSaleAbroad:
                minimumValue = 50
                maximumValue = 400
            case .businessSale, .businessLetting:
                minimumValue = 50
                maximumValue = 1500
            default:
                minimumValue = 30
                maximumValue = 400
            }

            return .configuration(minimumValue: minimumValue, maximumValue: maximumValue, increment: 5, unit: .squareMeters)
        case .plotArea:
            return .configuration(minimumValue: 300, maximumValue: 6000, increment: 50, unit: .squareMeters)
        case .constructionYear:
            return .yearConfiguration(minimumValue: 1900)
        default:
            return nil
        }
    }

    public func stepperConfiguration(forKey key: String) -> StepperFilterConfiguration? {
        guard let filterKey = FilterKey(stringValue: key) else {
            return nil
        }

        switch filterKey {
        case .noOfBedrooms:
            return StepperFilterConfiguration(minimumValue: 0, maximumValue: 6, unit: "stk", alternativeUnit: "soverom")
        default:
            return nil
        }
    }
}
