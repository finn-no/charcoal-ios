//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import FilterKit
import XCTest

/*
 public protocol FilterSelectionDataSource: AnyObject {
 func selectionState(_ filterInfo: MultiLevelListSelectionFilterInfoType) -> MultiLevelListItemSelectionState
 func value(for filterInfo: FilterInfoType) -> [String]?
 func valueAndSubLevelValues(for filterInfo: FilterInfoType) -> [FilterSelectionInfo]
 func setValue(_ filterSelectionValue: [String]?, for filterInfo: FilterInfoType)
 func addValue(_ value: String, for filterInfo: FilterInfoType)
 func clearAll(for filterInfo: FilterInfoType)
 func clearValue(_ value: String, for filterInfo: FilterInfoType)

 func rangeValue(for filterInfo: RangeFilterInfoType) -> RangeValue?
 func setValue(_ range: RangeValue, for filterInfo: RangeFilterInfoType)
 }
 */

class ParameterBasedFilterInfoSelectionDataSourceTests: XCTestCase {
    func testSelectionDataSourceShouldPreserveInitValues() {
        let filter = MockParameterBasedFilterInfo(parameterName: "test", title: "Test")

        let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource(queryItems: [URLQueryItem(name: filter.parameterName, value: "value"), URLQueryItem(name: "foo", value: "bar")])

        let values = selectionDataSource.value(for: filter)
        XCTAssertNotNil(values)
        XCTAssertEqual(1, values!.count)
        XCTAssertEqual("value", values!.first!)
    }

    func testSelectionDataSourceShouldSupportMultipleValuesForFilterAtInit() {
        let filter = MockParameterBasedFilterInfo(parameterName: "test", title: "Test")

        let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource(queryItems: [URLQueryItem(name: filter.parameterName, value: "value"), URLQueryItem(name: filter.parameterName, value: "value2"), URLQueryItem(name: "foo", value: "bar")])

        let values = selectionDataSource.value(for: filter)
        XCTAssertNotNil(values)
        XCTAssertEqual(2, values!.count)
        XCTAssertTrue(values!.contains("value"))
        XCTAssertTrue(values!.contains("value2"))
    }

    func testSelectionDataSourceShouldSupportRemovingAllSelectionValues() {
        let filter = MockParameterBasedFilterInfo(parameterName: "test", title: "Test")
        let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource(queryItems: [URLQueryItem(name: filter.parameterName, value: "value"), URLQueryItem(name: filter.parameterName, value: "value2"), URLQueryItem(name: "foo", value: "bar")])

        selectionDataSource.clearAll(for: filter)

        let values = selectionDataSource.value(for: filter)
        XCTAssertNil(values)
    }

    func testSelectionDataSourceShouldSupportRemovingOnly1SelectionValue() {
        let filter = MockParameterBasedFilterInfo(parameterName: "test", title: "Test")
        let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource(queryItems: [URLQueryItem(name: filter.parameterName, value: "value"), URLQueryItem(name: filter.parameterName, value: "value2"), URLQueryItem(name: "foo", value: "bar")])

        selectionDataSource.clearValue("value", for: filter)

        let values = selectionDataSource.value(for: filter)
        XCTAssertNotNil(values)
        XCTAssertEqual(1, values!.count)
        XCTAssertEqual("value2", values!.first!)
    }

    func testSelectionDataSourceShouldSupportOverridingMultipleValuesWithNewValues() {
        let filter = MockParameterBasedFilterInfo(parameterName: "test", title: "Test")
        let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource(queryItems: [URLQueryItem(name: filter.parameterName, value: "value"), URLQueryItem(name: filter.parameterName, value: "value2"), URLQueryItem(name: "foo", value: "bar")])

        selectionDataSource.setValue(["new", "new2"], for: filter)

        let values = selectionDataSource.value(for: filter)
        XCTAssertNotNil(values)
        XCTAssertEqual(2, values!.count)
        XCTAssertTrue(values!.contains("new"))
        XCTAssertTrue(values!.contains("new2"))
    }
}

class MockParameterBasedFilterInfo: ParameterBasedFilterInfo {
    var parameterName: String
    var title: String

    init(parameterName: String, title: String) {
        self.parameterName = parameterName
        self.title = title
    }
}
