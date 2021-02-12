@testable import CharcoalDemo
import Charcoal
import XCTest

class FilterContainerTests: XCTestCase {

    private func snapshot(_ filterContainer: FilterContainer, delay: TimeInterval? = nil, record recording: Bool = false, testName: String = #function) {
        assertSnapshots(matching: filterContainer, delay: delay, record: recording, testName: testName)
    }

    // MARK: - Tests

    func testSingleVertical() {
        snapshot(.singleVertical)
    }
    func testMultipleVerticals() {
        snapshot(.multipleVerticals)
    }
    func testContextFilter() {
        snapshot(.contextFilter)
    }
    func testPolygonSearchDisabled() {
        snapshot(.polygonSearchDisabled)
    }
}
