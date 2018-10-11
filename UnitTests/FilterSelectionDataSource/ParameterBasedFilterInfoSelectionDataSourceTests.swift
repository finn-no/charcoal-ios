//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import FilterKit
import XCTest

/*
 public protocol FilterSelectionDataSource: AnyObject {
 func selectionState(_ filterInfo: MultiLevelListSelectionFilterInfoType) -> MultiLevelListItemSelectionState
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
            XCTAssertTrue(false, "Casting failed")
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

    func testSelectionDataSourceShouldSupportInitWithFiltersSharingParameterName() {
        let parentFilter = createMultiLevelFilter(parameterName: "foo", title: "Foo", multiSelect: true, value: "foo")
        let childFilter = createMultiLevelFilter(parameterName: "foo", title: "Bar", multiSelect: true, value: "bar")

        let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource(queryItems: [URLQueryItem(name: parentFilter.parameterName, value: parentFilter.value), URLQueryItem(name: childFilter.parameterName, value: childFilter.value)])

        let selectionValues = selectionDataSource.selectionValues["foo"]
        guard let fooValues = selectionValues else {
            XCTAssertTrue(false, "Casting failed")
            return
        }
        XCTAssertEqual(2, fooValues.count)
        XCTAssertTrue(fooValues.contains("foo"))
        XCTAssertTrue(fooValues.contains("bar"))
    }

    func testSelectionDataSourceShouldSupportGettingSubLevelValuesForMultiLevelFilters() {
        let createdObjects = createCategoryLevels()
        let selectionDataSource = createdObjects.selectionDataSource
        let category = createdObjects.category
        let kitchenTables = createdObjects.kitchenTables
        let otherTables = createdObjects.otherTables
        let animals = createdObjects.animals

        selectionDataSource.addValue(kitchenTables.value, for: kitchenTables)
        selectionDataSource.addValue(otherTables.value, for: otherTables)
        selectionDataSource.addValue(animals.value, for: animals)

        let selectionValues = selectionDataSource.valueAndSubLevelValues(for: category)
        XCTAssertEqual(3, selectionValues.count)
        guard let selectionDataValues = selectionValues as? [FilterSelectionDataInfo] else {
            XCTAssertTrue(false, "Casting failed")
            return
        }
        XCTAssertTrue(selectionDataValues.contains(where: { ($0.filter as? MultiLevelListSelectionFilterInfo) == kitchenTables }))
        XCTAssertTrue(selectionDataValues.contains(where: { ($0.filter as? MultiLevelListSelectionFilterInfo) == otherTables }))
        XCTAssertTrue(selectionDataValues.contains(where: { ($0.filter as? MultiLevelListSelectionFilterInfo) == animals }))
    }

    func testSelectionDataSourceShouldSupportClearing1FilterOnlyWhenMultiLevelFiltersShareParameter() {
        let parentFilter = createMultiLevelFilter(parameterName: "foo", title: "Foo", multiSelect: true, value: "123")
        let childFilter = createMultiLevelFilter(parameterName: "foo", title: "Bar", multiSelect: true, value: "456")
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

    func testSelectionDataSourceShouldSupportClearing1FilterOnlyWhenMultiLevelFiltersDoesntShareParameter() {
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

    func testSelectionDataSourceShouldSupportGettingSelectionStateForMultiLevelFilters() {
        let createdObjects = createCategoryLevels()
        let selectionDataSource = createdObjects.selectionDataSource
        let category = createdObjects.category
        let kitchenTables = createdObjects.kitchenTables
        let otherTables = createdObjects.otherTables
        let animals = createdObjects.animals

        selectionDataSource.addValue(kitchenTables.value, for: kitchenTables)
        selectionDataSource.addValue(animals.value, for: animals)

        XCTAssertEqual(.partial, selectionDataSource.selectionState(category))
        XCTAssertEqual(.partial, selectionDataSource.selectionState(kitchenTables.parent!))
        XCTAssertEqual(.selected, selectionDataSource.selectionState(animals))
        XCTAssertEqual(.selected, selectionDataSource.selectionState(kitchenTables))
        XCTAssertEqual(.none, selectionDataSource.selectionState(otherTables))
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

    func createCategoryLevels() -> (selectionDataSource: ParameterBasedFilterInfoSelectionDataSource, category: MultiLevelListSelectionFilterInfo, kitchenTables: MultiLevelListSelectionFilterInfo, otherTables: MultiLevelListSelectionFilterInfo, animals: MultiLevelListSelectionFilterInfo) {
        let category = createMultiLevelFilter(parameterName: "category", title: "Kategori", multiSelect: true, value: "")
        let furniture = createMultiLevelFilter(parameterName: "category", title: "Møbler", multiSelect: true, value: "Møbler")
        let tables = createMultiLevelFilter(parameterName: "sub_category", title: "Bord", multiSelect: true, value: "Bord")
        let kitchenTables = createMultiLevelFilter(parameterName: "product_type", title: "Kjøkkenbord", multiSelect: true, value: "Kjøkkenbord")
        let otherTables = createMultiLevelFilter(parameterName: "product_type", title: "Andre bord", multiSelect: true, value: "Andre bord")
        let animals = createMultiLevelFilter(parameterName: "category", title: "Dyr", multiSelect: true, value: "Dyr")
        let fishes = createMultiLevelFilter(parameterName: "sub_category", title: "Fisker", multiSelect: true, value: "Fisker")
        let birds = createMultiLevelFilter(parameterName: "sub_category", title: "Fugler", multiSelect: true, value: "Fugler")

        category.setSubLevelFilters([furniture, animals])
        furniture.setSubLevelFilters([tables])
        tables.setSubLevelFilters([kitchenTables, otherTables])
        animals.setSubLevelFilters([fishes, birds])

        let selectionDataSource = ParameterBasedFilterInfoSelectionDataSource(queryItems: [])
        selectionDataSource.multiLevelFilterLookup = [furniture.lookupKey: furniture, tables.lookupKey: tables, kitchenTables.lookupKey: kitchenTables, otherTables.lookupKey: otherTables, animals.lookupKey: animals, fishes.lookupKey: fishes, birds.lookupKey: birds]

        return (selectionDataSource, category, kitchenTables, otherTables, animals)
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
