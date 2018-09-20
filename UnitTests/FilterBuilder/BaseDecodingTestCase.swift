//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import FilterKit
import XCTest

class BaseDecodingTestCase: XCTestCase {
    func dataFromJSONFile(named name: String) -> Data? {
        let bundle = Bundle(for: FilterDecodingTests.self)

        guard let path = bundle.path(forResource: name, ofType: "json") else {
            return nil
        }

        return try? Data(contentsOf: URL(fileURLWithPath: path))
    }

    func filterDataFromJSONFile(named name: String) -> FilterSetup? {
        guard let data = dataFromJSONFile(named: name) else {
            return nil
        }

        return try? JSONDecoder().decode(FilterSetup.self, from: data)
    }
}
