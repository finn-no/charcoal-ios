//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

class Filter {
    let title: String
    let name: String
    let value: String?
    let numberOfResults: Int
    private(set) var subfilters: [Filter] = []
    private(set) weak var parent: Filter?

    // MARK: - Init

    init(title: String, name: String, value: String? = nil, numberOfResults: Int = 0) {
        self.title = title
        self.name = name
        self.value = value
        self.numberOfResults = numberOfResults
    }

    // MARK: - Public methods

    func add(subfilter: Filter, at index: Int? = nil) {
        if let index = index {
            subfilters.insert(subfilter, at: index)
        } else {
            subfilters.append(subfilter)
        }
        subfilter.parent = self
    }

    func subfilter(at index: Int) -> Filter? {
        guard index < subfilters.count else { return nil }
        return subfilters[index]
    }
}
