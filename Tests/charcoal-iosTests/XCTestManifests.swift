import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(charcoal_iosTests.allTests),
    ]
}
#endif
