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
        let buildResult = builder?.build()
        let numberOfSearchQueryFilterInfoElements = buildResult?.searchQuery != nil ? 1 : 0
        let numberOfPreferenceFilterInfoElements = buildResult?.preferences.count
        let numberOfRangeFilterInfoElements = buildResult?.filters.reduce(0, { ($1 is RangeFilterInfoType) ? $0 + 1 : $0 })
        let numberOfMultiLevelListSelectionFilterInfoElements = buildResult?.filters.reduce(0, { ($1 is MultiLevelListSelectionFilterInfo) ? $0 + 1 : $0 })
        let numberOfListSelectionFilterInfoElements = buildResult?.filters.reduce(0, { ($1 is ListSelectionFilterInfo) ? $0 + 1 : $0 })

        // Then
        XCTAssertNotNil(filter)
        XCTAssertNotNil(builder)
        XCTAssertNotNil(buildResult)
        XCTAssertEqual(numberOfSearchQueryFilterInfoElements, 1)
        XCTAssertEqual(numberOfPreferenceFilterInfoElements, 4)
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
        let buildResult = builder?.build()
        let preferenceFilterInfos = buildResult?.preferences
        let publishedPreference = preferenceFilterInfos?.first(where: { $0.title == "Publisert" })
        let publishedFilterData = filter?.filterData(forKey: .published)

        // Then
        XCTAssertNotNil(buildResult)
        XCTAssertNotNil(preferenceFilterInfos)
        XCTAssertNotNil(publishedFilterData)

        XCTAssertEqual(preferenceFilterInfos?.count, FilterMarket.car(.norway).preferenceFilterKeys.count)

        XCTAssertNotNil(publishedPreference)
        XCTAssertEqual(publishedPreference?.title, "Publisert")
        XCTAssertEqual(publishedPreference?.title, publishedFilterData?.title)

        XCTAssertEqual(publishedPreference?.values.count, 1)
        XCTAssertEqual(publishedPreference?.values.count, publishedFilterData?.queries.count)

        XCTAssertNotNil(publishedPreference?.values.first)
        XCTAssertNotNil(publishedFilterData?.queries.first)

        XCTAssertEqual(publishedPreference?.values.first?.title, "Nye i dag")
        XCTAssertEqual(publishedPreference?.values.first?.title, publishedFilterData?.queries.first?.title)

        guard let firstValue = publishedPreference?.values.first else {
            return
        }
        let numberOfHitsForFirstValue = buildResult?.filterValueLookup[firstValue.lookupKey]?.results
        XCTAssertEqual(numberOfHitsForFirstValue, 2307)
        XCTAssertEqual(numberOfHitsForFirstValue, publishedFilterData?.queries.first?.totalResults)
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
        let buildResult = builder?.build()
        let makeMultiLevelFilterInfo = buildResult?.filters.first(where: { $0.title == "Merke" }) as? MultiLevelListSelectionFilterInfoType
        let makeFilterData = filter?.filterData(forKey: .make)

        // Then
        XCTAssertNotNil(buildResult)
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
        let buildResult = builder?.build()
        let rangeFilterData = filter?.filters.first(where: { $0.isRange == true })
        let rangeFilterName = rangeFilterData?.title
        let rangeFilterInfo = buildResult?.filters.first(where: { $0.title == rangeFilterName }) as? RangeFilterInfoType

        // Then
        XCTAssertNotNil(buildResult)
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
