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
        XCTAssertEqual(FilterUnit.centimeters.value, "unit.centimeters".localized())
        XCTAssertEqual(FilterUnit.cubicCentimeters.value, "unit.cubicCentimeters".localized())
        XCTAssertEqual(FilterUnit.currency.value, "unit.currency".localized())
        XCTAssertEqual(FilterUnit.feet.value, "unit.feet".localized())
        XCTAssertEqual(FilterUnit.horsePower.value, "unit.horsePower".localized())
        XCTAssertEqual(FilterUnit.items.value, "unit.items".localized())
        XCTAssertEqual(FilterUnit.kilograms.value, "unit.kilograms".localized())
        XCTAssertEqual(FilterUnit.kilometers.value, "unit.kilometers".localized())
        XCTAssertEqual(FilterUnit.seats.value, "unit.seats".localized())
        XCTAssertEqual(FilterUnit.squareMeters.value, "unit.squareMeters".localized())
        XCTAssertTrue(FilterUnit.year.value.isEmpty)
        XCTAssertEqual(customUnit.value, "value")
    }

    func testAccessibilityValue() {
        XCTAssertTrue(FilterUnit.centimeters.accessibilityValue.isEmpty)
        XCTAssertTrue(FilterUnit.cubicCentimeters.accessibilityValue.isEmpty)
        XCTAssertTrue(FilterUnit.currency.accessibilityValue.isEmpty)
        XCTAssertTrue(FilterUnit.feet.accessibilityValue.isEmpty)
        XCTAssertTrue(FilterUnit.horsePower.accessibilityValue.isEmpty)
        XCTAssertTrue(FilterUnit.items.accessibilityValue.isEmpty)
        XCTAssertTrue(FilterUnit.kilograms.accessibilityValue.isEmpty)
        XCTAssertTrue(FilterUnit.kilometers.accessibilityValue.isEmpty)
        XCTAssertTrue(FilterUnit.seats.accessibilityValue.isEmpty)
        XCTAssertTrue(FilterUnit.squareMeters.accessibilityValue.isEmpty)
        XCTAssertTrue(FilterUnit.year.accessibilityValue.isEmpty)
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

    func testTilValueText() {
        XCTAssertEqual(FilterUnit.centimeters.tilValueText, "to".localized())
        XCTAssertEqual(FilterUnit.cubicCentimeters.tilValueText, "to".localized())
        XCTAssertEqual(FilterUnit.currency.tilValueText, "to".localized())
        XCTAssertEqual(FilterUnit.feet.tilValueText, "to".localized())
        XCTAssertEqual(FilterUnit.horsePower.tilValueText, "to".localized())
        XCTAssertEqual(FilterUnit.items.tilValueText, "to".localized())
        XCTAssertEqual(FilterUnit.kilograms.tilValueText, "to".localized())
        XCTAssertEqual(FilterUnit.kilometers.tilValueText, "to".localized())
        XCTAssertEqual(FilterUnit.seats.tilValueText, "to".localized())
        XCTAssertEqual(FilterUnit.squareMeters.tilValueText, "to".localized())
        XCTAssertEqual(FilterUnit.year.tilValueText, "before".localized().lowercased())
        XCTAssertEqual(customUnit.tilValueText, "to".localized())
    }
}
