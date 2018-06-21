//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import FilterKit
import XCTest

class FilterInfoBuilderTests: BaseTestCase {
    lazy var decodedTestFilter: Filter? = {
        return filterDataFromJSONFile(named: "FilterInfoBuildersTestsFilter")
    }()

    func testFilterInfoBuilderBuildsExpectedFilterInfoElementsFromFilter() {
        // Given
        let filter = decodedTestFilter
        let builder: FilterInfoBuilder?
        if let filter = filter {
            builder = FilterInfoBuilder(filter: filter)
        } else {
            builder = nil
        }

        // When
        let filterInfoElements = builder?.build()
        let numberOfFreeSearchFilterInfoElements = filterInfoElements?.reduce(0, { ($1 is FreeSearchFilterInfoType) ? $0 + 1 : $0 })
        let numberOfPreferenceFilterInfoElements = filterInfoElements?.reduce(0, { ($1 is PreferenceFilterInfoType) ? $0 + 1 : $0 })
        let numberOfRangeFilterInfoElements = filterInfoElements?.reduce(0, { ($1 is RangeFilterInfoType) ? $0 + 1 : $0 })
        let numberOfMultiLevelFilterInfoElements = filterInfoElements?.reduce(0, { ($1 is MultilevelFilterInfo) ? $0 + 1 : $0 })

        // Then
        XCTAssertNotNil(filter)
        XCTAssertNotNil(builder)
        XCTAssertNotNil(filterInfoElements)
        XCTAssertEqual(filterInfoElements?.count, 19)
        XCTAssertEqual(numberOfFreeSearchFilterInfoElements, 1)
        XCTAssertEqual(numberOfPreferenceFilterInfoElements, 1)
        XCTAssertEqual(numberOfRangeFilterInfoElements, 5)
        XCTAssertEqual(numberOfMultiLevelFilterInfoElements, 12)
    }

    func testFilterInfoBuilderBuildsPreferenceFilterInfoWithExpectedValues() {
        // Given
        let filter = decodedTestFilter
        let builder: FilterInfoBuilder?
        if let filter = filter {
            builder = FilterInfoBuilder(filter: filter)
        } else {
            builder = nil
        }

        // When
        let filterInfoElements = builder?.build()
        let preferenceFilterInfo = filterInfoElements?.first(where: { $0 is PreferenceFilterInfoType }) as? PreferenceFilterInfoType
        let preferenceFilterInfoPreferences = preferenceFilterInfo?.preferences
        let publishedPreference = preferenceFilterInfoPreferences?.first(where: { $0.name == "Publisert" })
        let publishedFilterData = filter?.filterData(forKey: .published)

        // Then
        XCTAssertNotNil(filterInfoElements)
        XCTAssertNotNil(preferenceFilterInfo)
        XCTAssertNotNil(preferenceFilterInfoPreferences)
        XCTAssertNotNil(publishedFilterData)

        XCTAssertEqual(preferenceFilterInfoPreferences?.count, FilterKey.preferenceFilterKeys(forMarket: .car).count)

        XCTAssertNotNil(publishedPreference)
        XCTAssertEqual(publishedPreference?.name, "Publisert")
        XCTAssertEqual(publishedPreference?.name, publishedFilterData?.title)

        XCTAssertEqual(publishedPreference?.values.count, 1)
        XCTAssertEqual(publishedPreference?.values.count, publishedFilterData?.queries?.count)

        XCTAssertNotNil(publishedPreference?.values.first)
        XCTAssertNotNil(publishedFilterData?.queries?.first)

        XCTAssertEqual(publishedPreference?.values.first?.title, "Nye i dag")
        XCTAssertEqual(publishedPreference?.values.first?.title, publishedFilterData?.queries?.first?.title)

        XCTAssertEqual(publishedPreference?.values.first?.results, 2309)
        XCTAssertEqual(publishedPreference?.values.first?.results, publishedFilterData?.queries?.first?.totalResults)
    }

    func testFilterInfoBuilderBuildsMultiLevelFilterInfoWithExpectedValues() {
        // Given
        let filter = decodedTestFilter
        let builder: FilterInfoBuilder?
        if let filter = filter {
            builder = FilterInfoBuilder(filter: filter)
        } else {
            builder = nil
        }

        // When
        let filterInfoElements = builder?.build()
        let makeMultiLevelFilterInfo = filterInfoElements?.first(where: { $0.name == "Merke" }) as? MultiLevelFilterInfoType
        let makeFilterData = filter?.filterData(forKey: .make)

        // Then
        XCTAssertNotNil(filterInfoElements)
        XCTAssertNotNil(makeMultiLevelFilterInfo)
        XCTAssertNotNil(makeFilterData)
        XCTAssertEqual(makeMultiLevelFilterInfo?.name, "Merke")
        XCTAssertEqual(makeMultiLevelFilterInfo?.name, makeFilterData?.title)
        XCTAssertEqual(makeMultiLevelFilterInfo?.filters.count, 86)
        XCTAssertEqual(makeMultiLevelFilterInfo?.filters.count, makeFilterData?.queries?.count)

        XCTAssertNotNil(makeMultiLevelFilterInfo?.filters.first)
        XCTAssertNotNil(makeFilterData?.queries?.first)

        XCTAssertEqual(makeMultiLevelFilterInfo?.filters.first?.name, "Abarth")
        XCTAssertEqual(makeMultiLevelFilterInfo?.filters.first?.name, makeFilterData?.queries?.first?.title)

        XCTAssertEqual(makeMultiLevelFilterInfo?.filters.first?.results, 6)
        XCTAssertEqual(makeMultiLevelFilterInfo?.filters.first?.results, makeFilterData?.queries?.first?.totalResults)

        XCTAssertEqual(makeMultiLevelFilterInfo?.filters.first?.filters.count, 3)
        XCTAssertEqual(makeMultiLevelFilterInfo?.filters.first?.filters.count, makeFilterData?.queries?.first?.filter?.queries.count)

        XCTAssertNotNil(makeMultiLevelFilterInfo?.filters.first?.filters.first)
        XCTAssertNotNil(makeFilterData?.queries?.first?.filter?.queries.first)

        XCTAssertEqual(makeMultiLevelFilterInfo?.filters.first?.filters.first?.name, "124 Spider")
        XCTAssertEqual(makeMultiLevelFilterInfo?.filters.first?.filters.first?.name, makeFilterData?.queries?.first?.filter?.queries.first?.title)

        XCTAssertEqual(makeMultiLevelFilterInfo?.filters.first?.filters.first?.results, 2)
        XCTAssertEqual(makeMultiLevelFilterInfo?.filters.first?.filters.first?.results, makeFilterData?.queries?.first?.filter?.queries.first?.totalResults)
    }
}
