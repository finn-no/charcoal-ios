//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

final class FilterUnitTests: XCTestCase {
    private let customUnit = FilterUnit.custom(
        value: "value",
        accessibilityValue: "accessibility",
        shouldFormatWithSeparator: false
    )

    func testValue() {
        XCTAssertEqual(FilterUnit.centimeters.value, "unit.centimeters.value".localized())
        XCTAssertEqual(FilterUnit.cubicCentimeters.value, "unit.cubicCentimeters.value".localized())
        XCTAssertEqual(FilterUnit.currency.value, "unit.currency.value".localized())
        XCTAssertEqual(FilterUnit.feet.value, "unit.feet.value".localized())
        XCTAssertEqual(FilterUnit.horsePower.value, "unit.horsePower.value".localized())
        XCTAssertEqual(FilterUnit.items.value, "unit.items.value".localized())
        XCTAssertEqual(FilterUnit.kilograms.value, "unit.kilograms.value".localized())
        XCTAssertEqual(FilterUnit.kilometers.value, "unit.kilometers.value".localized())
        XCTAssertEqual(FilterUnit.seats.value, "unit.seats.value".localized())
        XCTAssertEqual(FilterUnit.squareMeters.value, "unit.squareMeters.value".localized())
        XCTAssertTrue(FilterUnit.year.value.isEmpty)
        XCTAssertEqual(customUnit.value, "value")
    }

    func testAccessibilityValue() {
        XCTAssertEqual(FilterUnit.centimeters.accessibilityValue, "unit.centimeters.accessibilityValue".localized())
        XCTAssertEqual(FilterUnit.cubicCentimeters.accessibilityValue, "unit.cubicCentimeters.accessibilityValue".localized())
        XCTAssertEqual(FilterUnit.currency.accessibilityValue, "unit.currency.accessibilityValue".localized())
        XCTAssertEqual(FilterUnit.feet.accessibilityValue, "unit.feet.accessibilityValue".localized())
        XCTAssertEqual(FilterUnit.horsePower.accessibilityValue, "unit.horsePower.accessibilityValue".localized())
        XCTAssertEqual(FilterUnit.items.accessibilityValue, "unit.items.accessibilityValue".localized())
        XCTAssertEqual(FilterUnit.kilograms.accessibilityValue, "unit.kilograms.accessibilityValue".localized())
        XCTAssertEqual(FilterUnit.kilometers.accessibilityValue, "unit.kilometers.accessibilityValue".localized())
        XCTAssertEqual(FilterUnit.seats.accessibilityValue, "unit.seats.accessibilityValue".localized())
        XCTAssertEqual(FilterUnit.squareMeters.accessibilityValue, "unit.squareMeters.accessibilityValue".localized())
        XCTAssertEqual(FilterUnit.year.accessibilityValue, "unit.years.accessibilityValue".localized())
        XCTAssertEqual(customUnit.accessibilityValue, "accessibility")
    }

    func testShouldFormatWithSeparator() {
        XCTAssertTrue(FilterUnit.centimeters.shouldFormatWithSeparator)
        XCTAssertTrue(FilterUnit.cubicCentimeters.shouldFormatWithSeparator)
        XCTAssertTrue(FilterUnit.currency.shouldFormatWithSeparator)
        XCTAssertTrue(FilterUnit.feet.shouldFormatWithSeparator)
        XCTAssertTrue(FilterUnit.horsePower.shouldFormatWithSeparator)
        XCTAssertTrue(FilterUnit.items.shouldFormatWithSeparator)
        XCTAssertTrue(FilterUnit.kilograms.shouldFormatWithSeparator)
        XCTAssertTrue(FilterUnit.kilometers.shouldFormatWithSeparator)
        XCTAssertTrue(FilterUnit.seats.shouldFormatWithSeparator)
        XCTAssertTrue(FilterUnit.squareMeters.shouldFormatWithSeparator)
        XCTAssertFalse(FilterUnit.year.shouldFormatWithSeparator)
        XCTAssertFalse(customUnit.shouldFormatWithSeparator)
    }

    func testLowerBoundText() {
        XCTAssertEqual(FilterUnit.centimeters.lowerBoundText, "under".localized())
        XCTAssertEqual(FilterUnit.cubicCentimeters.lowerBoundText, "under".localized())
        XCTAssertEqual(FilterUnit.currency.lowerBoundText, "under".localized())
        XCTAssertEqual(FilterUnit.feet.lowerBoundText, "under".localized())
        XCTAssertEqual(FilterUnit.horsePower.lowerBoundText, "under".localized())
        XCTAssertEqual(FilterUnit.items.lowerBoundText, "under".localized())
        XCTAssertEqual(FilterUnit.kilograms.lowerBoundText, "under".localized())
        XCTAssertEqual(FilterUnit.kilometers.lowerBoundText, "under".localized())
        XCTAssertEqual(FilterUnit.seats.lowerBoundText, "under".localized())
        XCTAssertEqual(FilterUnit.squareMeters.lowerBoundText, "under".localized())
        XCTAssertEqual(FilterUnit.year.lowerBoundText, "before".localized())
        XCTAssertEqual(customUnit.lowerBoundText, "under".localized())
    }

    func testUpperBoundText() {
        XCTAssertEqual(FilterUnit.centimeters.upperBoundText, "over".localized())
        XCTAssertEqual(FilterUnit.cubicCentimeters.upperBoundText, "over".localized())
        XCTAssertEqual(FilterUnit.currency.upperBoundText, "over".localized())
        XCTAssertEqual(FilterUnit.feet.upperBoundText, "over".localized())
        XCTAssertEqual(FilterUnit.horsePower.upperBoundText, "over".localized())
        XCTAssertEqual(FilterUnit.items.upperBoundText, "over".localized())
        XCTAssertEqual(FilterUnit.kilograms.upperBoundText, "over".localized())
        XCTAssertEqual(FilterUnit.kilometers.upperBoundText, "over".localized())
        XCTAssertEqual(FilterUnit.seats.upperBoundText, "over".localized())
        XCTAssertEqual(FilterUnit.squareMeters.upperBoundText, "over".localized())
        XCTAssertEqual(FilterUnit.year.upperBoundText, "after".localized())
        XCTAssertEqual(customUnit.upperBoundText, "over".localized())
    }

    func testFromValueText() {
        XCTAssertEqual(FilterUnit.centimeters.fromValueText, "from".localized())
        XCTAssertEqual(FilterUnit.cubicCentimeters.fromValueText, "from".localized())
        XCTAssertEqual(FilterUnit.currency.fromValueText, "from".localized())
        XCTAssertEqual(FilterUnit.feet.fromValueText, "from".localized())
        XCTAssertEqual(FilterUnit.horsePower.fromValueText, "from".localized())
        XCTAssertEqual(FilterUnit.items.fromValueText, "from".localized())
        XCTAssertEqual(FilterUnit.kilograms.fromValueText, "from".localized())
        XCTAssertEqual(FilterUnit.kilometers.fromValueText, "from".localized())
        XCTAssertEqual(FilterUnit.seats.fromValueText, "from".localized())
        XCTAssertEqual(FilterUnit.squareMeters.fromValueText, "from".localized())
        XCTAssertEqual(FilterUnit.year.fromValueText, "after".localized().lowercased())
        XCTAssertEqual(customUnit.fromValueText, "from".localized())
    }

    func testToValueText() {
        XCTAssertEqual(FilterUnit.centimeters.toValueText, "upTo".localized())
        XCTAssertEqual(FilterUnit.cubicCentimeters.toValueText, "upTo".localized())
        XCTAssertEqual(FilterUnit.currency.toValueText, "upTo".localized())
        XCTAssertEqual(FilterUnit.feet.toValueText, "upTo".localized())
        XCTAssertEqual(FilterUnit.horsePower.toValueText, "upTo".localized())
        XCTAssertEqual(FilterUnit.items.toValueText, "upTo".localized())
        XCTAssertEqual(FilterUnit.kilograms.toValueText, "upTo".localized())
        XCTAssertEqual(FilterUnit.kilometers.toValueText, "upTo".localized())
        XCTAssertEqual(FilterUnit.seats.toValueText, "upTo".localized())
        XCTAssertEqual(FilterUnit.squareMeters.toValueText, "upTo".localized())
        XCTAssertEqual(FilterUnit.year.toValueText, "before".localized().lowercased())
        XCTAssertEqual(customUnit.toValueText, "upTo".localized())
    }
}
