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
    func setValue<T: LosslessStringConvertible>(_ value: T?, for node: CCFilterNode) {
        selections[node.key] = value.map(String.init)
    }

    func removeValue(for node: CCFilterNode, withChildren: Bool = false) {
        selections.removeValue(forKey: node.key)

        if withChildren {
            node.children.forEach {
                removeValue(for: $0, withChildren: withChildren)
            }
        }
    }

    func toggleValue(for node: CCFilterNode) {
        if isSelected(node: node) {
            removeValue(for: node)
        } else {
            setValue(node.value, for: node)
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

            if lowValue == nil && highValue == nil {
                return []
            } else {
                return ["\(lowValue ?? "...") - \(highValue ?? "...")"]
            }
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
