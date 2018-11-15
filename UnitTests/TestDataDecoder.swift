//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

protocol TestDataDecoder {
    func dataFromJSONFile(named name: String) -> Data?
    func filterDataFromJSONFile(named name: String) -> FilterSetup?
    func filterDataFromDictionaryDecodedFromJSONFile(named name: String) -> FilterSetup?
}

extension TestDataDecoder {
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

    func filterDataFromDictionaryDecodedFromJSONFile(named name: String) -> FilterSetup? {
        guard let data = dataFromJSONFile(named: name) else {
            return nil
        }

        guard let decodedData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [AnyHashable: Any] else {
            return nil
        }

        return FilterSetup.decode(from: decodedData)
    }
}
