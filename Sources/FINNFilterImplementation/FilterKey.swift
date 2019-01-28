//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public enum FilterKey: String, CodingKey {
    case animalsAllowed = "animals_allowed"
    case area
    case boatClass = "class"
    case bodyType = "body_type"
    case caravanDealerSegment = "caravan_dealer_segment"
    case caravanSegment = "caravan_segment"
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
    case furnished
    case industry
    case isNewProperty = "is_new_property"
    case isPrivateBroker = "is_private_broker"
    case isSold = "is_sold"
    case jobDuration = "job_duration"
    case jobSector = "job_sector"
    case leasepriceInit = "leaseprice_init"
    case leasepriceMonth = "leaseprice_month"
    case leisureSituation = "leisure_situation"
    case length
    case lengthFeet = "length_feet"
    case location
    case make
    case managerRole = "manager_role"
    case markets
    case mileage
    case mobileHomeSegment = "mobile_home_segment"
    case motorAdLocation = "motor_ad_location"
    case motorIncluded = "motor_included"
    case motorSize = "motor_size"
    case motorType = "motor_type"
    case noOfBedrooms = "no_of_bedrooms"
    case noOfOccupants = "no_of_occupants"
    case noOfSeats = "no_of_seats"
    case noOfSleepers = "no_of_sleepers"
    case numberOfSeats = "number_of_seats"
    case occupation
    case ownershipType = "ownership_type"
    case plotArea = "plot_area"
    case plotOwned = "plot_owned"
    case price
    case priceChanged = "price_changed"
    case priceCollective = "price_collective"
    case propertyType = "property_type"
    case published
    case query = "q"
    case registrationClass = "registration_class"
    case rent
    case rentFrom = "rent_from"
    case salesForm = "sales_form"
    case searchType = "search_type"
    case segment
    case transmission
    case type
    case viewing
    case warrantyInsurance = "warranty_insurance"
    case weight
    case width
    case wheelDrive = "wheel_drive"
    case wheelSets = "wheel_sets"
    case year
}
