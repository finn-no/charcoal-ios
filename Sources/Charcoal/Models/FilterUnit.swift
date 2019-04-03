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
        shouldFormatWithSeparator: Bool
    )

    public var value: String {
        switch self {
        case .centimeters:
            return "unit.centimeters.value".localized()
        case .cubicCentimeters:
            return "unit.cubicCentimeters.value".localized()
        case .currency:
            return "unit.currency.value".localized()
        case .feet:
            return "unit.feet.value".localized()
        case .horsePower:
            return "unit.horsePower.value".localized()
        case .items:
            return "unit.items.value".localized()
        case .kilograms:
            return "unit.kilograms.value".localized()
        case .kilometers:
            return "unit.kilometers.value".localized()
        case .seats:
            return "unit.seats.value".localized()
        case .squareMeters:
            return "unit.squareMeters.value".localized()
        case .year:
            return ""
        case let .custom(value, _, _):
            return value
        }
    }

    public var accessibilityValue: String {
        switch self {
        case .centimeters:
            return "unit.centimeters.accessibilityValue".localized()
        case .cubicCentimeters:
            return "unit.cubicCentimeters.accessibilityValue".localized()
        case .currency:
            return "unit.currency.accessibilityValue".localized()
        case .feet:
            return "unit.feet.accessibilityValue".localized()
        case .horsePower:
            return "unit.horsePower.accessibilityValue".localized()
        case .items:
            return "unit.items.accessibilityValue".localized()
        case .kilograms:
            return "unit.kilograms.accessibilityValue".localized()
        case .kilometers:
            return "unit.kilometers.accessibilityValue".localized()
        case .seats:
            return "unit.seats.accessibilityValue".localized()
        case .squareMeters:
            return "unit.squareMeters.accessibilityValue".localized()
        case .year:
            return "unit.years.accessibilityValue".localized()
        case let .custom(_, accessibilityValue, _):
            return accessibilityValue
        }
    }

    public var shouldFormatWithSeparator: Bool {
        switch self {
        case .year:
            return false
        case let .custom(_, _, shouldFormatWithSeparator):
            return shouldFormatWithSeparator
        default:
            return true
        }
    }

    public var lowerBoundText: String {
        switch self {
        case .year:
            return "before".localized()
        default:
            return "under".localized()
        }
    }

    public var upperBoundText: String {
        switch self {
        case .year:
            return "after".localized()
        default:
            return "over".localized()
        }
    }

    public var fromValueText: String {
        switch self {
        case .year:
            return "after".localized().lowercased()
        default:
            return "from".localized().lowercased()
        }
    }

    public var toValueText: String {
        switch self {
        case .year:
            return "before".localized().lowercased()
        default:
            return "upTo".localized().lowercased()
        }
    }
}
