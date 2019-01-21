//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public enum FilterKey: String, CodingKey {
    case query = "q"

    // bap
    case published
    case location
    case segment
    case searchType = "search_type"
    case condition
    case category
    case price

    // car
    case markets
    case make
    case dealerSegment = "dealer_segment"
    case salesForm = "sales_form"
    case year
    case mileage
    case priceChanged = "price_changed"
    case bodyType = "body_type"
    case engineFuel = "engine_fuel"
    case exteriorColour = "exterior_colour"
    case engineEffect = "engine_effect"
    case numberOfSeats = "number_of_seats"
    case wheelDrive = "wheel_drive"
    case transmission
    case carEquipment = "car_equipment"
    case wheelSets = "wheel_sets"
    case warrantyInsurance = "warranty_insurance"
    case registrationClass = "registration_class"

    // realestate
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

    // job
    case occupation
    case industry
    case extent
    case jobDuration = "job_duration"
    case jobSector = "job_sector"
    case managerRole = "manager_role"
}
