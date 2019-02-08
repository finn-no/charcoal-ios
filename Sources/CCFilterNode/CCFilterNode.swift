//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

private protocol CCFilterNodeDelegate: class {
    func childNodeDidChangeSelection(_ childNode: CCFilterNode)
}

public class CCFilterNode {

    // MARK: - Public properties

    public let title: String
    public let name: String
    public var value: String?
    public var numberOfResults: Int

    public var isSelected: Bool {
        didSet { delegate?.childNodeDidChangeSelection(self) }
    }

    // MARK: - Private properties

    private(set) var children: [CCFilterNode] = []
    private weak var delegate: CCFilterNodeDelegate?

    // MARK: - Setup

    public init(title: String, name: String, value: String? = nil, isSelected: Bool = false, numberOfResults: Int = 0) {
        self.title = title
        self.name = name
        self.value = value
        self.isSelected = isSelected
        self.numberOfResults = numberOfResults
    }

    // MARK: - Public methods

    func add(child: CCFilterNode, at index: Int? = nil) {
        if let index = index { children.insert(child, at: index) }
        else { children.append(child) }
        child.delegate = self
    }

    func child(at index: Int) -> CCFilterNode {
        return children[index]
    }

    func reset() {
        isSelected = false
        children.forEach { $0.reset() }
    }

    var isLeafNode: Bool {
        return children.count == 0
    }

    var urlItems: [String] {
        if isSelected, let value = value {
            return ["\(name)=\(value)"]
        }
        return children.reduce([]) { $0 + $1.urlItems }
    }
}

extension CCFilterNode: CCFilterNodeDelegate {
    func childNodeDidChangeSelection(_ childNode: CCFilterNode) {
        isSelected = children.reduce(true) { $0 && $1.isSelected }
    }
}
