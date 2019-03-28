//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public enum FilterUnit: Equatable {
    case centimeters
    case cubicCentimeters
    case currency
    case feet
    case horsePower
    case items
    case kilograms
    case kilometers
    case seats
    case squareMeters
    case year
    case custom(
        value: String,
        accessibilityValue: String,
        shouldFormatWithSeparator: Bool,
        shouldDisplayInNumberInput: Bool,
        lowerBoundTitle: String,
        upperBoundTitle: String
    )

    public var value: String {
        switch self {
        case .centimeters:
            return "unit.centimeters".localized()
        case .cubicCentimeters:
            return "unit.cubicCentimeters".localized()
        case .currency:
            return "unit.currency".localized()
        case .feet:
            return "unit.feet".localized()
        case .horsePower:
            return "unit.horsePower".localized()
        case .items:
            return "unit.items.".localized()
        case .kilograms:
            return "unit.kilograms".localized()
        case .kilometers:
            return "unit.kilometers".localized()
        case .seats:
            return "unit.seats".localized()
        case .squareMeters:
            return "unit.squareMeters".localized()
        case .year:
            return "unit.year".localized()
        case let .custom(value, _, _, _, _, _):
            return value
        }
    }

    public var accessibilityValue: String {
        switch self {
        case let .custom(_, accessibilityValue, _, _, _, _):
            return accessibilityValue
        default:
            return ""
        }
    }

    public var shouldFormatWithSeparator: Bool {
        switch self {
        case .year:
            return false
        case let .custom(_, _, shouldFormatWithSeparator, _, _, _):
            return shouldFormatWithSeparator
        default:
            return true
        }
    }

    public var shouldDisplayInNumberInput: Bool {
        switch self {
        case .year:
            return false
        case let .custom(_, _, _, shouldDisplayInNumberInput, _, _):
            return shouldDisplayInNumberInput
        default:
            return true
        }
    }

    public var lowerBoundTitle: String {
        switch self {
        case .year:
            return "before".localized()
        case let .custom(_, _, _, _, lowerBoundTitle, _):
            return lowerBoundTitle
        default:
            return "under".localized()
        }
    }

    public var upperBoundTitle: String {
        switch self {
        case .year:
            return "after".localized()
        case let .custom(_, _, _, _, _, upperBoundTitle):
            return upperBoundTitle
        default:
            return "over".localized()
        }
    }
}
