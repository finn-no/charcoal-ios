//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

extension CCMapFilterNode {
    enum Key: String, CaseIterable {
        case lat, lon, radius, geoLocationName
    }

    enum Index: Int, CaseIterable {
        case lat, lon, radius, geoLocationName
    }
}

class CCMapFilterNode: CCFilterNode {
    static let filterKey = "map"

    init(title: String, name: String) {
        super.init(title: title, name: name, value: nil, isSelected: false, numberOfResults: 0)
        setup()
    }
}

extension CCMapFilterNode {
    func setup() {
        children = Index.allCases.map { CCFilterNode(title: "", name: Key.allCases[$0.rawValue].rawValue) }
    }
}
