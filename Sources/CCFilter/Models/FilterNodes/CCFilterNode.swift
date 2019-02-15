//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class CCFilterNode {
    public let title: String
    public let name: String
    public let value: String?
    public let numberOfResults: Int
    private(set) var children: [CCFilterNode] = []
    private(set) weak var parent: CCFilterNode?

    public var id: String {
        let value = self.value.map({ ".\($0)" }) ?? ""
        return "\(title.lowercased()).\(name)\(value)"
    }

    public var isLeafNode: Bool {
        return children.isEmpty
    }

    // MARK: - Init

    public init(title: String, name: String, value: String? = nil, numberOfResults: Int = 0) {
        self.title = title
        self.name = name
        self.value = value
        self.numberOfResults = numberOfResults
    }

    // MARK: - Public methods

    public func add(child: CCFilterNode, at index: Int? = nil) {
        if let index = index {
            children.insert(child, at: index)
        } else {
            children.append(child)
        }
        child.parent = self
    }

    public func child(at index: Int) -> CCFilterNode? {
        guard index < children.count else { return nil }
        return children[index]
    }
}
