//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class CCFilterNode {

    // MARK: - Public properties

    public let title: String
    public let name: String
    public let value: String?
    public let numberOfResults: Int

    // MARK: - Private properties

    private(set) var children: [CCFilterNode] = []
    private(set) weak var parent: CCFilterNode?

    // MARK: - Setup

    public init(title: String, name: String, value: String? = nil, numberOfResults: Int = 0) {
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

    var isLeafNode: Bool {
        return children.isEmpty
    }

    var key: String {
        let value = self.value ?? ""
        return "\(name).\(title.lowercased())\(value)"
    }
}
