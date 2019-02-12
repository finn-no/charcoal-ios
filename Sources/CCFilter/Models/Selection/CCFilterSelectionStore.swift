//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

final class FilterSelectionStore {
    private var selections = [String: String]()

    func isSelected(node: CCFilterNode) -> Bool {
        return value(for: node) != nil
    }

    func toggle(node: CCFilterNode) {
        if isSelected(node: node) {
            unselect(node: node)
        } else if let value = node.value {
            select(node: node)
        }
    }

    func select(node: CCFilterNode, value: String? = nil) {
        selections[node.key] = node.value ?? value
        // isSelected = children.reduce(true) { $0 && $1.isSelected }
    }

    func value(for node: CCFilterNode) -> String? {
        return selections[node.key]
    }

    func unselect(node: CCFilterNode) {
        selections.removeValue(forKey: node.key)

        node.children.forEach {
            unselect(node: $0)
        }

        updateSelection(for: node)
    }

    private func updateSelection(for node: CCFilterNode) {
//        node.isSelected = children.allSatisfy { $0.isSelected }
//
//        func childNodeDidChangeSelection(_ childNode: CCFilterNode) {
//
//        }
    }

    func urlItems(for node: CCFilterNode) -> [String] {
        if let value = value(for: node) {
            return ["\(node.key)=\(value)"]
        }

        return node.children.reduce([]) { $0 + urlItems(for: $1) }
    }

    func queryItems(for node: CCFilterNode) -> [URLQueryItem] {
        if let value = value(for: node) {
            return [URLQueryItem(name: node.key, value: value)]
        }

        return node.children.reduce([]) { $0 + queryItems(for: $1) }
    }

    func titles(for node: CCFilterNode) -> [String] {
        if isSelected(node: node) {
            return buildTitles(for: node)
        }

        return node.children.reduce([]) { $0 + titles(for: $1) }
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

    private func buildTitles(for node: CCFilterNode) -> [String] {
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
        } else {
            return [node.title]
        }
    }
}

// MARK: - Private

private extension CCFilterNode {
    var key: String {
        return name
    }
}
