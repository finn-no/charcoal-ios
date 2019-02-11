//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class CCRangeFilterNode: CCFilterNode {

    // MARK: - Internal properties

    let lowValueNode: CCFilterNode
    let highValueNode: CCFilterNode

    public init(title: String, name: String) {
        lowValueNode = CCFilterNode(title: "", name: name + "_from")
        highValueNode = CCFilterNode(title: "", name: name + "_to")
        super.init(title: title, name: name)
        setup()
    }

    override var queryItems: [URLQueryItem] {
        if isSelected {
            guard let lowValue = lowValueNode.value, let highValue = highValueNode.value else { return [] }
            let fromItem = URLQueryItem(name: lowValueNode.name, value: lowValue)
            let toItem = URLQueryItem(name: highValueNode.name, value: highValue)
            return [fromItem, toItem]
        } else {
            return lowValueNode.queryItems + highValueNode.queryItems
        }
    }

    override func reset() {
        isSelected = false
        reset(lowValueNode)
        reset(highValueNode)
    }

    private func reset(_ child: CCFilterNode) {
        child.value = nil
        child.isSelected = false
    }
}

extension CCRangeFilterNode {
    func setup() {
        add(child: lowValueNode)
        add(child: highValueNode)
    }
}
