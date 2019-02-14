//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

final class FilterSelectionStore {
    private var selections = [String: String]()

    func value(for node: CCFilterNode) -> String? {
        return selections[node.key]
    }

    func value<T: LosslessStringConvertible>(for node: CCFilterNode) -> T? {
        return selections[node.key].flatMap(T.init)
    }

    func clear() {
        selections.removeAll()
    }
}

// MARK: - Selection

extension FilterSelectionStore {
    func select(node: CCFilterNode) {
        selections[node.key] = node.value
    }

    func select<T: LosslessStringConvertible>(node: CCFilterNode, value: T? = nil) {
        selections[node.key] = value.map(String.init)
    }

    func deselect(node: CCFilterNode, withChildren: Bool = false) {
        selections.removeValue(forKey: node.key)

        if withChildren {
            node.children.forEach {
                deselect(node: $0, withChildren: true)
            }
        }
    }

    func toggle(node: CCFilterNode) {
        if isSelected(node: node) {
            deselect(node: node)
        } else {
            select(node: node)
        }
    }

    func isSelected(node: CCFilterNode) -> Bool {
        let selected: Bool

        if node is CCMapFilterNode || node is CCRangeFilterNode {
            selected = node.children.contains(where: { isSelected(node: $0) })
        } else {
            selected = !node.children.isEmpty && node.children.allSatisfy { isSelected(node: $0) }
        }

        return value(for: node) != nil || selected
    }
}

// MARK: - Helpers

extension FilterSelectionStore {
    func queryItems(for node: CCFilterNode) -> [URLQueryItem] {
        if let value = value(for: node) {
            return [URLQueryItem(name: node.name, value: value)]
        }

        return node.children.reduce([]) { $0 + queryItems(for: $1) }
    }

    func titles(for node: CCFilterNode) -> [String] {
        if let rangeNode = node as? CCRangeFilterNode {
            let lowValue = value(for: rangeNode.lowValueNode)
            let highValue = value(for: rangeNode.highValueNode)
            if let lowValue = lowValue, let highValue = highValue {
                return ["\(lowValue) - \(highValue)"]
            } else if let lowValue = lowValue {
                return ["\(lowValue) - ..."]
            } else if let highValue = highValue {
                return ["... - \(highValue)"]
            } else {
                return []
            }
        } else if let mapNode = node as? CCMapFilterNode, hasSelectedChildren(node: mapNode) {
            return ["map_filter_title".localized()]
        } else if isSelected(node: node) {
            return [node.title]
        } else {
            return node.children.reduce([]) { $0 + titles(for: $1) }
        }
    }

    func hasSelectedChildren(node: CCFilterNode) -> Bool {
        if isSelected(node: node) {
            return true
        }

        return node.children.reduce(false) { $0 || hasSelectedChildren(node: $1) }
    }

    func selectedChildren(for node: CCFilterNode) -> [CCFilterNode] {
        if isSelected(node: node) {
            return [node]
        }

        return node.children.reduce([]) { $0 + selectedChildren(for: $1) }
    }
}
