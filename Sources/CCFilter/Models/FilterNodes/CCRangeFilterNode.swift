//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

extension CCRangeFilterNode {
    enum Key: String, CaseIterable {
        case from = "_from", to = "_to"
    }

    enum Index: Int, CaseIterable {
        case from, to
    }
}

public class CCRangeFilterNode: CCFilterNode {
    public init(title: String, name: String) {
        super.init(title: title, name: name)
        setup()
    }

    override var urlItems: [String] {
        let fromNode = child(at: Index.from.rawValue)
        let toNode = child(at: Index.to.rawValue)

        if isSelected {
            guard let fromValue = fromNode.value, let toValue = toNode.value else { return [] }
            let fromItem = "\(fromNode.name)=\(fromValue)"
            let toItem = "\(toNode.name)=\(toValue)"
            return [fromItem, toItem]
        } else {
            return fromNode.urlItems + toNode.urlItems
        }
    }
}

extension CCRangeFilterNode {
    func setup() {
        Index.allCases.forEach {
            add(child: CCFilterNode(title: "", name: name + Key.allCases[$0.rawValue].rawValue))
        }
    }
}
