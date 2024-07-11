@testable import CharcoalDemo
import Charcoal
import SnapshotTesting
import XCTest

class FilterContainerTests: XCTestCase {

    private func snapshot(
        _ filterContainer: FilterContainer,
        verticals: [DemoVertical] = .multiple,
        showReloadVerticalsButton: Bool = false,
        record recording: Bool = false,
        testName: String = #function
    ) {
        assertSnapshots(
            matching: filterContainer,
            verticals: verticals,
            showReloadVerticalsButton: showReloadVerticalsButton,
            delay: 0.1,
            record: recording,
            testName: testName
        )
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
    func testFailedToLoadVerticals() {
        snapshot(.standard, verticals: .none, showReloadVerticalsButton: true)
    }
    func testContextFilter() {
        snapshot(.contextFilter)
    }
    func testPolygonSearchDisabled() {
        snapshot(.polygonSearchDisabled)
    }
}
