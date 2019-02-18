//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

class CCFilterNode {
    let title: String
    let name: String
    let value: String?
    let numberOfResults: Int
    private(set) var children: [CCFilterNode] = []
    private(set) weak var parent: CCFilterNode?

    var id: String {
        let value = self.value.map({ ".\($0)" }) ?? ""
        return "\(title.lowercased()).\(name)\(value)"
    }

    var isLeafNode: Bool {
        return children.isEmpty
    }

    // MARK: - Init

    init(title: String, name: String, value: String? = nil, numberOfResults: Int = 0) {
        self.title = title
        self.name = name
        self.value = value
        self.numberOfResults = numberOfResults
    }

    // MARK: - Public methods

    func add(child: CCFilterNode, at index: Int? = nil) {
        if let index = index {
            children.insert(child, at: index)
        } else {
            children.append(child)
        }
        child.parent = self
    }

    func child(at index: Int) -> CCFilterNode? {
        guard index < children.count else { return nil }
        return children[index]
    }
}
