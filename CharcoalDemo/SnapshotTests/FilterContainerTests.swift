@testable import CharcoalDemo
import Charcoal
import SnapshotTesting
import XCTest

class FilterContainerTests: XCTestCase {

    private func snapshot(
        _ filterContainer: FilterContainer,
        verticals: [DemoVertical] = .multiple,
        record recording: Bool = false,
        testName: String = #function
    ) {
        assertSnapshots(matching: filterContainer, delay: 0.1, record: recording, testName: testName)
    }

    override func setUp() {
        super.setUp()

        // used in SnapshotTesting error messages
        diffTool = "ksdiff"
    }

    // MARK: - Tests

    func testSingleVertical() {
        snapshot(.standard, verticals: .none)
    }
    func testMultipleVerticals() {
        snapshot(.standard, verticals: .multiple)
    }
    func testContextFilter() {
        snapshot(.contextFilter)
    }
    func testPolygonSearchDisabled() {
        snapshot(.polygonSearchDisabled)
    }
}
