//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

class FilterInfoBuilderTests: XCTestCase, TestDataDecoder {
    lazy var decodedTestFilter: FilterSetup? = {
        return filterDataFromJSONFile(named: "FilterInfoBuildersTestsFilter")
    }()

    func testFilterInfoBuilderBuildsExpectedFilterInfoElementsFromFilter() {
        // Given
        let filter = decodedTestFilter
        let builder: FilterInfoBuilder?
        if let filter = filter {
            builder = FilterInfoBuilder(filter: filter, selectionDataSource: ParameterBasedFilterInfoSelectionDataSource(queryItems: []))
        } else {
            builder = nil
        }

        // When
        let filterInfoElements = builder?.build()
        let numberOfSearchQueryFilterInfoElements = filterInfoElements?.reduce(0, { ($1 is SearchQueryFilterInfoType) ? $0 + 1 : $0 })
        let numberOfPreferenceFilterInfoElements = filterInfoElements?.reduce(0, { ($1 is PreferenceFilterInfoType) ? $0 + 1 : $0 })
        let numberOfRangeFilterInfoElements = filterInfoElements?.reduce(0, { ($1 is RangeFilterInfoType) ? $0 + 1 : $0 })
        let numberOfMultiLevelListSelectionFilterInfoElements = filterInfoElements?.reduce(0, { ($1 is MultiLevelListSelectionFilterInfo) ? $0 + 1 : $0 })
        let numberOfListSelectionFilterInfoElements = filterInfoElements?.reduce(0, { ($1 is ListSelectionFilterInfo) ? $0 + 1 : $0 })

        // Then
        XCTAssertNotNil(filter)
        XCTAssertNotNil(builder)
        XCTAssertNotNil(filterInfoElements)
        XCTAssertEqual(filterInfoElements?.count, 19)
        XCTAssertEqual(numberOfSearchQueryFilterInfoElements, 1)
        XCTAssertEqual(numberOfPreferenceFilterInfoElements, 1)
        XCTAssertEqual(numberOfRangeFilterInfoElements, 5)
        XCTAssertEqual(numberOfMultiLevelListSelectionFilterInfoElements, 1)
        XCTAssertEqual(numberOfListSelectionFilterInfoElements, 11)
    }

    func testFilterInfoBuilderBuildsPreferenceFilterInfoWithExpectedValues() {
        // Given
        let filter = decodedTestFilter
        let builder: FilterInfoBuilder?
        if let filter = filter {
            builder = FilterInfoBuilder(filter: filter, selectionDataSource: ParameterBasedFilterInfoSelectionDataSource(queryItems: []))
        } else {
            builder = nil
        }

        // When
        let filterInfoElements = builder?.build()
        let preferenceFilterInfo = filterInfoElements?.first(where: { $0 is PreferenceFilterInfoType }) as? PreferenceFilterInfoType
        let preferenceFilterInfoPreferences = preferenceFilterInfo?.preferences
        let publishedPreference = preferenceFilterInfoPreferences?.first(where: { $0.preferenceName == "Publisert" })
        let publishedFilterData = filter?.filterData(forKey: .published)

        // Then
        XCTAssertNotNil(filterInfoElements)
        XCTAssertNotNil(preferenceFilterInfo)
        XCTAssertNotNil(preferenceFilterInfoPreferences)
        XCTAssertNotNil(publishedFilterData)

        XCTAssertEqual(preferenceFilterInfoPreferences?.count, FilterMarket.car.preferenceFilterKeys.count)

        XCTAssertNotNil(publishedPreference)
        XCTAssertEqual(publishedPreference?.preferenceName, "Publisert")
        XCTAssertEqual(publishedPreference?.preferenceName, publishedFilterData?.title)

        XCTAssertEqual(publishedPreference?.values.count, 1)
        XCTAssertEqual(publishedPreference?.values.count, publishedFilterData?.queries.count)

        XCTAssertNotNil(publishedPreference?.values.first)
        XCTAssertNotNil(publishedFilterData?.queries.first)

        XCTAssertEqual(publishedPreference?.values.first?.title, "Nye i dag")
        XCTAssertEqual(publishedPreference?.values.first?.title, publishedFilterData?.queries.first?.title)

        XCTAssertEqual(publishedPreference?.values.first?.results, 2307)
        XCTAssertEqual(publishedPreference?.values.first?.results, publishedFilterData?.queries.first?.totalResults)
    }

    func testFilterInfoBuilderBuildsMultiLevelFilterInfoWithExpectedValues() {
        // Given
        let filter = decodedTestFilter
        let builder: FilterInfoBuilder?
        if let filter = filter {
            builder = FilterInfoBuilder(filter: filter, selectionDataSource: ParameterBasedFilterInfoSelectionDataSource(queryItems: []))
        } else {
            builder = nil
        }

        // When
        let filterInfoElements = builder?.build()
        let makeMultiLevelFilterInfo = filterInfoElements?.first(where: { $0.title == "Merke" }) as? MultiLevelListSelectionFilterInfoType
        let makeFilterData = filter?.filterData(forKey: .make)

        // Then
        XCTAssertNotNil(filterInfoElements)
        XCTAssertNotNil(makeMultiLevelFilterInfo)
        XCTAssertNotNil(makeFilterData)
        XCTAssertEqual(makeMultiLevelFilterInfo?.title, "Merke")
        XCTAssertEqual(makeMultiLevelFilterInfo?.title, makeFilterData?.title)
        XCTAssertEqual(makeMultiLevelFilterInfo?.filters.count, 84)
        XCTAssertEqual(makeMultiLevelFilterInfo?.filters.count, makeFilterData?.queries.count)

        XCTAssertNotNil(makeMultiLevelFilterInfo?.filters.first)
        XCTAssertNotNil(makeFilterData?.queries.first)

        XCTAssertEqual(makeMultiLevelFilterInfo?.filters.first?.title, "Abarth")
        XCTAssertEqual(makeMultiLevelFilterInfo?.filters.first?.title, makeFilterData?.queries.first?.title)

        XCTAssertEqual(makeMultiLevelFilterInfo?.filters.first?.results, 9)
        XCTAssertEqual(makeMultiLevelFilterInfo?.filters.first?.results, makeFilterData?.queries.first?.totalResults)

        XCTAssertEqual(makeMultiLevelFilterInfo?.filters.first?.filters.count, 3)
        XCTAssertEqual(makeMultiLevelFilterInfo?.filters.first?.filters.count, makeFilterData?.queries.first?.filter?.queries.count)

        XCTAssertNotNil(makeMultiLevelFilterInfo?.filters.first?.filters.first)
        XCTAssertNotNil(makeFilterData?.queries.first?.filter?.queries.first)

        XCTAssertEqual(makeMultiLevelFilterInfo?.filters.first?.filters.first?.title, "124 Spider")
        XCTAssertEqual(makeMultiLevelFilterInfo?.filters.first?.filters.first?.title, makeFilterData?.queries.first?.filter?.queries.first?.title)

        XCTAssertEqual(makeMultiLevelFilterInfo?.filters.first?.filters.first?.results, 2)
        XCTAssertEqual(makeMultiLevelFilterInfo?.filters.first?.filters.first?.results, makeFilterData?.queries.first?.filter?.queries.first?.totalResults)
    }

    func testFilterInfoBuilderBuildsRangeFilterInfoIfFilterDataIsRange() {
        // Given
        let filter = decodedTestFilter
        let builder: FilterInfoBuilder?
        if let filter = filter {
            builder = FilterInfoBuilder(filter: filter, selectionDataSource: ParameterBasedFilterInfoSelectionDataSource(queryItems: []))
        } else {
            builder = nil
        }

        // When
        let filterInfoElements = builder?.build()
        let rangeFilterData = filter?.filters.first(where: { $0.isRange == true })
        let rangeFilterName = rangeFilterData?.title
        let rangeFilterInfo = filterInfoElements?.first(where: { $0.title == rangeFilterName }) as? RangeFilterInfoType

        // Then
        XCTAssertNotNil(filterInfoElements)
        XCTAssertNotNil(rangeFilterData)
        XCTAssertNotNil(rangeFilterName)
        XCTAssertNotNil(rangeFilterInfo)
    }

    func testFilterDataWithQueriesWithoutFiltersIsListSelectionFilter() {
        // Given
        let filterDataElement = decodedTestFilter?.filterData(forKey: .transmission)

        // When
        let isSelectionFilter = FilterInfoBuilder.isListSelectionFilter(filterData: filterDataElement!)
        let isMultiLevelSelectionFilter = FilterInfoBuilder.isMultiLevelListSelectionFilter(filterData: filterDataElement!)

        XCTAssertNotNil(isSelectionFilter)
        XCTAssertEqual(isSelectionFilter, true)
        XCTAssertEqual(isMultiLevelSelectionFilter, false)
    }

    func testFilterDataWithQueriesWithFiltersiltersIsMultiLevelListSelectionFilter() {
        // Given
        let filterDataElementOrNil = decodedTestFilter?.filterData(forKey: .make)

        guard let filterDataElement = filterDataElementOrNil else {
            XCTAssertNotNil(filterDataElementOrNil)
            return
        }

        // When
        let isSelectionFilter = FilterInfoBuilder.isListSelectionFilter(filterData: filterDataElement)
        let isMultiLevelSelectionFilter = FilterInfoBuilder.isMultiLevelListSelectionFilter(filterData: filterDataElement)

        XCTAssertNotNil(isSelectionFilter)
        XCTAssertEqual(isSelectionFilter, false)
        XCTAssertEqual(isMultiLevelSelectionFilter, true)
    }
}
