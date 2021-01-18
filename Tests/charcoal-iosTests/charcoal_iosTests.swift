import XCTest
@testable import charcoal_ios

final class charcoal_iosTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(charcoal_ios().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
