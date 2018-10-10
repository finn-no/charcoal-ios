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
 }
 */

class ParameterBasedFilterInfoSelectionDataSourceTests: XCTestCase {
    func testSelectionDataSourceShouldPreserveInitValues() {
        let filter = MockFilterInfo(parameterName: "test", title: "Test")

        let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource(queryItems: [URLQueryItem(name: filter.parameterName, value: "value"), URLQueryItem(name: "foo", value: "bar")])

        let values = selectionDataSource.value(for: filter)
        XCTAssertNotNil(values)
        XCTAssertEqual(1, values!.count)
        XCTAssertEqual("value", values!.first!)
    }

    func testSelectionDataSourceShouldSupportMultipleValuesForFilterAtInit() {
        let filter = MockFilterInfo(parameterName: "test", title: "Test")

        let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource(queryItems: [URLQueryItem(name: filter.parameterName, value: "value"), URLQueryItem(name: filter.parameterName, value: "value2"), URLQueryItem(name: "foo", value: "bar")])

        let values = selectionDataSource.value(for: filter)
        XCTAssertNotNil(values)
        XCTAssertEqual(2, values!.count)
        XCTAssertTrue(values!.contains("value"))
        XCTAssertTrue(values!.contains("value2"))
    }

    func testSelectionDataSourceShouldSupportRemovingAllSelectionValues() {
        let filter = MockFilterInfo(parameterName: "test", title: "Test")
        let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource(queryItems: [URLQueryItem(name: filter.parameterName, value: "value"), URLQueryItem(name: filter.parameterName, value: "value2"), URLQueryItem(name: "foo", value: "bar")])

        selectionDataSource.clearAll(for: filter)

        let values = selectionDataSource.value(for: filter)
        XCTAssertNil(values)
    }

    func testSelectionDataSourceShouldSupportRemovingOnly1SelectionValue() {
        let filter = MockFilterInfo(parameterName: "test", title: "Test")
        let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource(queryItems: [URLQueryItem(name: filter.parameterName, value: "value"), URLQueryItem(name: filter.parameterName, value: "value2"), URLQueryItem(name: "foo", value: "bar")])

        selectionDataSource.clearValue("value", for: filter)

        let values = selectionDataSource.value(for: filter)
        XCTAssertNotNil(values)
        XCTAssertEqual(1, values!.count)
        XCTAssertEqual("value2", values!.first!)
    }

    func testSelectionDataSourceShouldSupportOverridingMultipleValuesWithNewValues() {
        let filter = MockFilterInfo(parameterName: "test", title: "Test")
        let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource(queryItems: [URLQueryItem(name: filter.parameterName, value: "value"), URLQueryItem(name: filter.parameterName, value: "value2"), URLQueryItem(name: "foo", value: "bar")])

        selectionDataSource.setValue(["new", "new2"], for: filter)

        let values = selectionDataSource.value(for: filter)
        XCTAssertNotNil(values)
        XCTAssertEqual(2, values!.count)
        XCTAssertTrue(values!.contains("new"))
        XCTAssertTrue(values!.contains("new2"))
    }

    func testSelectionDataSourceShouldSupportAddingToExistingValues() {
        let filter = MockFilterInfo(parameterName: "test", title: "Test")
        let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource(queryItems: [URLQueryItem(name: filter.parameterName, value: "value"), URLQueryItem(name: filter.parameterName, value: "value2"), URLQueryItem(name: "foo", value: "bar")])

        selectionDataSource.addValue("new", for: filter)

        let values = selectionDataSource.value(for: filter)
        XCTAssertNotNil(values)
        XCTAssertEqual(3, values!.count)
        XCTAssertTrue(values!.contains("new"))
    }

    func testSelectionDataSourceShouldSupportGettingClosedRangeValue() {
        let filter = createRangeFilter(parameterName: "test", title: "Test")
        let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource(queryItems: [URLQueryItem(name: filter.parameterName + "_from", value: "10"), URLQueryItem(name: filter.parameterName + "_to", value: "20"), URLQueryItem(name: "foo", value: "bar")])

        let range = selectionDataSource.rangeValue(for: filter)

        XCTAssertNotNil(range)
        guard case let .closed(min, max) = range! else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(10, min)
        XCTAssertEqual(20, max)
    }

    func testSelectionDataSourceShouldSupportGettingMinRangeValue() {
        let filter = createRangeFilter(parameterName: "test", title: "Test")
        let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource(queryItems: [URLQueryItem(name: filter.parameterName + "_from", value: "10"), URLQueryItem(name: "foo", value: "bar")])

        let range = selectionDataSource.rangeValue(for: filter)

        XCTAssertNotNil(range)
        guard case let .minimum(min) = range! else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(10, min)
    }

    func testSelectionDataSourceShouldSupportGettingMaxRangeValue() {
        let filter = createRangeFilter(parameterName: "test", title: "Test")
        let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource(queryItems: [URLQueryItem(name: filter.parameterName + "_to", value: "20"), URLQueryItem(name: "foo", value: "bar")])

        let range = selectionDataSource.rangeValue(for: filter)

        XCTAssertNotNil(range)
        guard case let .maximum(max) = range! else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(20, max)
    }

    func testSelectionDataSourceShouldSupportSettingMaxRangeValue() {
        let filter = createRangeFilter(parameterName: "test", title: "Test")
        let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource(queryItems: [])

        selectionDataSource.setValue(.maximum(highValue: 30), for: filter)

        let filterValues = selectionDataSource.selectionValues[filter.parameterName + "_to"]
        XCTAssertNotNil(filterValues)
        XCTAssertEqual(1, filterValues!.count)
        XCTAssertEqual("30", filterValues!.first!)
    }

    func testSelectionDataSourceShouldSupportSettingMinRangeValue() {
        let filter = createRangeFilter(parameterName: "test", title: "Test")
        let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource(queryItems: [])

        selectionDataSource.setValue(.minimum(lowValue: 30), for: filter)

        let filterValues = selectionDataSource.selectionValues[filter.parameterName + "_from"]
        XCTAssertNotNil(filterValues)
        XCTAssertEqual(1, filterValues!.count)
        XCTAssertEqual("30", filterValues!.first!)
    }

    func testSelectionDataSourceShouldSupportSettingClosedRangeValue() {
        let filter = createRangeFilter(parameterName: "test", title: "Test")
        let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource(queryItems: [])

        selectionDataSource.setValue(.closed(lowValue: 1, highValue: 2), for: filter)

        let minValues = selectionDataSource.selectionValues[filter.parameterName + "_from"]
        XCTAssertNotNil(minValues)
        XCTAssertEqual(1, minValues!.count)
        XCTAssertEqual("1", minValues!.first!)

        let maxValues = selectionDataSource.selectionValues[filter.parameterName + "_to"]
        XCTAssertNotNil(maxValues)
        XCTAssertEqual(1, maxValues!.count)
        XCTAssertEqual("2", maxValues!.first!)
    }

    func testSelectionDataSourceShouldSupportClearing1FilterOnlyWhenMultiLevelFiltersShareParameter() {
        let parentFilter = createMultiLevelFilter(parameterName: "foo", title: "Foo", multiSelect: true, value: "123")
        let childFilter = createMultiLevelFilter(parameterName: "bar", title: "Bar", multiSelect: true, value: "456")
        parentFilter.setSubLevelFilters([childFilter])
        let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource(queryItems: [URLQueryItem(name: parentFilter.parameterName, value: parentFilter.value), URLQueryItem(name: childFilter.parameterName, value: childFilter.value)])
        childFilter.updateSelectionState(selectionDataSource)
        parentFilter.updateSelectionState(selectionDataSource)
        selectionDataSource.multiLevelFilterLookup = [parentFilter.lookupKey: parentFilter, childFilter.lookupKey: childFilter]

        selectionDataSource.clearValue(parentFilter.value, for: parentFilter)

        let selectionValues = selectionDataSource.valueAndSubLevelValues(for: parentFilter)
        XCTAssertEqual(1, selectionValues.count)
        guard let selectionValue = selectionValues.first as? FilterSelectionDataInfo else {
            XCTAssertTrue(false, "Casting failed")
            return
        }
        XCTAssertEqual(1, selectionValue.value.count)
        XCTAssertEqual("456", selectionValue.value.first!)
    }
}

extension ParameterBasedFilterInfoSelectionDataSourceTests {
    func createRangeFilter(parameterName: String, title: String) -> RangeFilterInfo {
        let rangeFilter = RangeFilterInfo(parameterName: parameterName, title: title, lowValue: 10, highValue: 100, steps: 10, rangeBoundsOffsets: (lowerBoundOffset: 10, upperBoundOffset: 10), unit: "unit", referenceValues: [20, 50, 90], accesibilityValues: (accessibilitySteps: nil, accessibilityValueSuffix: nil), appearanceProperties: (usesSmallNumberInputFont: true, displaysUnitInNumberInput: true, isCurrencyValueRange: false))
        return rangeFilter
    }

    func createMultiLevelFilter(parameterName: String, title: String, multiSelect: Bool, value: String) -> MultiLevelListSelectionFilterInfo {
        let filter = MultiLevelListSelectionFilterInfo(parameterName: parameterName, title: title, isMultiSelect: multiSelect, results: 0, value: value)
        return filter
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
