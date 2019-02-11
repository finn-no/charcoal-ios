//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class CCRangeFilterNode: CCFilterNode {

    // MARK: - Internal properties

    let lowNode: CCFilterNode
    let highNode: CCFilterNode

    public init(title: String, name: String) {
        lowNode = CCFilterNode(title: "", name: name + "_from")
        highNode = CCFilterNode(title: "", name: name + "_to")
        super.init(title: title, name: name)
        setup()
    }

    override var queryItems: [URLQueryItem] {
        if isSelected {
            guard let lowValue = lowNode.value, let highValue = highNode.value else { return [] }
            let fromItem = URLQueryItem(name: lowNode.name, value: lowValue)
            let toItem = URLQueryItem(name: highNode.name, value: highValue)
            return [fromItem, toItem]
        } else {
            return lowNode.queryItems + highNode.queryItems
        }
    }

    override func reset() {
        isSelected = false
        reset(lowNode)
        reset(highNode)
    }

    private func reset(_ child: CCFilterNode) {
        child.value = nil
        child.isSelected = false
    }
}

extension CCRangeFilterNode {
    func setup() {
        add(child: lowNode)
        add(child: highNode)
    }
}
