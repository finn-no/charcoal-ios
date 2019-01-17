//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

class FilterSelectionDataTests: XCTestCase {
    func testSelectionDataShouldPreserveInitValues() {
        let filter = MockFilterInfo(parameterName: "test", title: "Test")

        let selectionData = FilterSelectionData(selectionValues: [filter.parameterName: ["value"], "foo": ["bar"]])

        let values = selectionData.selectionValues(for: filter.parameterName)

        XCTAssertEqual(1, values.count)
        XCTAssertEqual("value", values.first)
    }

    func testSelectionDataShouldSupportMultipleValuesForFilterAtInit() {
        let filter = MockFilterInfo(parameterName: "test", title: "Test")

        let selectionData = FilterSelectionData(selectionValues: [filter.parameterName: ["value", "value2"], "foo": ["bar"]])

        let values = selectionData.selectionValues(for: filter.parameterName)
        XCTAssertEqual(2, values.count)
        XCTAssertTrue(values.contains("value"))
        XCTAssertTrue(values.contains("value2"))
    }

    func testSelectionDataShouldSupportRemovingOnly1SelectionValue() {
        let filter = MockFilterInfo(parameterName: "test", title: "Test")
        let selectionData = FilterSelectionData(selectionValues: [filter.parameterName: ["value", "value2"], "foo": ["bar"]])

        selectionData.removeValue("value", for: filter)

        let values = selectionData.selectionValues(for: filter.parameterName)
        XCTAssertEqual(1, values.count)
        XCTAssertEqual("value2", values.first)
    }

    func testSelectionDataShouldSupportOverridingMultipleValuesWithNewValues() {
        let filter = MockFilterInfo(parameterName: "test", title: "Test")
        let selectionData = FilterSelectionData(selectionValues: [filter.parameterName: ["value", "value2"], "foo": ["bar"]])

        selectionData.setSelectionValues(["new", "new2"], for: filter.parameterName)

        let values = selectionData.selectionValues(for: filter.parameterName)
        XCTAssertEqual(2, values.count)
        XCTAssertTrue(values.contains("new"))
        XCTAssertTrue(values.contains("new2"))
    }

    func testSelectionDataShouldSupportAddingToExistingValues() {
        let filter = MockFilterInfo(parameterName: "test", title: "Test")
        let selectionData = FilterSelectionData(selectionValues: [filter.parameterName: ["value", "value2"], "foo": ["bar"]])

        selectionData.addValue("new", for: filter)

        let values = selectionData.selectionValues(for: filter.parameterName)
        XCTAssertEqual(3, values.count)
        XCTAssertTrue(values.contains("new"))
    }
}

private class MockFilterInfo: ParameterBasedFilterInfo {
    var parameterName: String
    var title: String

    init(parameterName: String, title: String) {
        self.parameterName = parameterName
        self.title = title
    }
}
