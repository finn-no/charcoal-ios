//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public enum FilterKey: String, CodingKey {
    case area
    case boatClass = "class"
    case bodyType = "body_type"
    case carEquipment = "car_equipment"
    case category
    case condition
    case constructionYear = "construction_year"
    case dealerSegment = "dealer_segment"
    case energyLabel = "energy_label"
    case engineEffect = "engine_effect"
    case engineFuel = "engine_fuel"
    case engineVolume = "engine_volume"
    case extent
    case exteriorColour = "exterior_colour"
    case facilities
    case floorNavigator = "floor_navigator"
    case fuel
    case industry
    case isNewProperty = "is_new_property"
    case isPrivateBroker = "is_private_broker"
    case isSold = "is_sold"
    case jobDuration = "job_duration"
    case jobSector = "job_sector"
    case lengthFeet = "length_feet"
    case location
    case make
    case managerRole = "manager_role"
    case markets
    case mileage
    case motorAdLocation = "motor_ad_location"
    case motorIncluded = "motor_included"
    case motorSize = "motor_size"
    case motorType = "motor_type"
    case noOfBedrooms = "no_of_bedrooms"
    case noOfSeats = "no_of_seats"
    case noOfSleepers = "no_of_sleepers"
    case numberOfSeats = "number_of_seats"
    case occupation
    case ownershipType = "ownership_type"
    case plotArea = "plot_area"
    case price
    case priceChanged = "price_changed"
    case priceCollective = "price_collective"
    case propertyType = "property_type"
    case published
    case query = "q"
    case registrationClass = "registration_class"
    case rent
    case salesForm = "sales_form"
    case searchType = "search_type"
    case segment
    case transmission
    case viewing
    case warrantyInsurance = "warranty_insurance"
    case wheelDrive = "wheel_drive"
    case wheelSets = "wheel_sets"
    case year
}
