//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public enum FilterKey: String, CodingKey {
    case query = "q"

    // MARK: - bap

    case published
    case location
    case segment
    case searchType = "search_type"
    case condition
    case category
    case price

    // MARK: - Shared: car, mc

    case make
    case year
    case mileage
    case engineEffect = "engine_effect"
    case dealerSegment = "dealer_segment"

    // MARK: - car

    case markets
    case salesForm = "sales_form"
    case priceChanged = "price_changed"
    case bodyType = "body_type"
    case engineFuel = "engine_fuel"
    case exteriorColour = "exterior_colour"
    case numberOfSeats = "number_of_seats"
    case wheelDrive = "wheel_drive"
    case transmission
    case carEquipment = "car_equipment"
    case wheelSets = "wheel_sets"
    case warrantyInsurance = "warranty_insurance"
    case registrationClass = "registration_class"

    // MARK: - mc

    case engineVolume = "engine_volume"

    // MARK: - realestate

    case noOfBedrooms = "no_of_bedrooms"
    case area
    case plotArea = "plot_area"
    case priceCollective = "price_collective"
    case constructionYear = "construction_year"
    case rent
    case isPrivateBroker = "is_private_broker"
    case facilities
    case viewing
    case isNewProperty = "is_new_property"
    case energyLabel = "energy_label"
    case isSold = "is_sold"
    case floorNavigator = "floor_navigator"
    case propertyType = "property_type"
    case ownershipType = "ownership_type"
}
