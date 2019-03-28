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
        shouldDisplayInNumberInput: Bool
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
        case let .custom(value, _, _, _):
            return value
        }
    }

    public var accessibilityValue: String {
        switch self {
        case let .custom(_, accessibilityValue, _, _):
            return accessibilityValue
        default:
            return ""
        }
    }

    public var shouldFormatWithSeparator: Bool {
        switch self {
        case .year:
            return false
        case let .custom(_, _, shouldFormatWithSeparator, _):
            return shouldFormatWithSeparator
        default:
            return true
        }
    }

    public var shouldDisplayInNumberInput: Bool {
        switch self {
        case .year:
            return false
        case let .custom(_, _, _, shouldDisplayInNumberInput):
            return shouldDisplayInNumberInput
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

    public var tilValueText: String {
        switch self {
        case .year:
            return "before".localized().lowercased()
        default:
            return "til".localized().lowercased()
        }
    }
}
