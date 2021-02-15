@testable import CharcoalDemo
import Charcoal
import SnapshotTesting
import XCTest

class ComponentTests: XCTestCase {

    private func snapshot(_ viewController: UIViewController, delay: TimeInterval? = 1, record recording: Bool = false, testName: String = #function) {
        assertSnapshots(
            matching: viewController,
            device: .iPhone,
            delay: delay,
            record: recording,
            file: #file,
            testName: testName
        )

        assertSnapshots(
            matching: viewController,
            device: .iPad,
            delay: delay,
            record: recording,
            file: #file,
            testName: testName
        )
    }

    override func setUp() {
        super.setUp()

        // used in SnapshotTesting error messages
        diffTool = "ksdiff"
    }

    // MARK: - Tests

    func testInlineFilter() {
        snapshot(InlineFilterDemoViewController())
    }

    func testRangeFilter() {
        snapshot(RangeFilterDemoViewController())
    }

    func testStepperFilter() {
        snapshot(StepperFilterDemoViewController())
    }
}
