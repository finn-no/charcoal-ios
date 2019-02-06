//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class CCFilterNode {
    public let title: String
    public let name: String
    public var value: String?
    public var isSelected: Bool
    public var numberOfResults: Int
    public var children: [CCFilterNode] = []

    public var selectionTitlesBuilder: CCSelectionTitlesBuilder?

    public init(title: String, name: String, value: String? = nil, isSelected: Bool = false, numberOfResults: Int = 0) {
        self.title = title
        self.name = name
        self.value = value
        self.isSelected = isSelected
        self.numberOfResults = numberOfResults
    }
}

public extension CCFilterNode {
    var selectionTitles: [String] {
        if let titlesBuilder = selectionTitlesBuilder {
            return titlesBuilder.build(children)
        }
        if isSelected { return [title] }
        return children.reduce([]) { $0 + $1.selectionTitles }
    }

    var hasSelectedChildren: Bool {
        if isSelected { return true }
        return children.reduce(false) { $0 || $1.hasSelectedChildren }
    }

    var urlItems: [String] {
        if isSelected, let value = value {
            return ["\(name)=\(value)"]
        }
        return children.reduce([]) { $0 + $1.urlItems }
    }
}

extension CCFilterNode: Equatable {
    public static func == (lhs: CCFilterNode, rhs: CCFilterNode) -> Bool {
        let equalName = lhs.name == rhs.name
        let equalValue = lhs.value == rhs.value
        return equalName && equalValue
    }
}
