//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

final class FilterSelectionStore {
    private var selections = [String: String]()

    func value(for node: CCFilterNode) -> String? {
        return selections[node.id]
    }

    func value<T: LosslessStringConvertible>(for node: CCFilterNode) -> T? {
        return selections[node.id].flatMap(T.init)
    }

    func clear() {
        selections.removeAll()
    }
}

// MARK: - Selection

extension FilterSelectionStore {
    func setValue(from node: CCFilterNode) {
        selections[node.id] = node.value
    }

    func setValue<T: LosslessStringConvertible>(_ value: T?, for node: CCFilterNode) {
        selections[node.id] = value.map(String.init)
    }

    func removeValues(for node: CCFilterNode) {
        selections.removeValue(forKey: node.id)

        node.children.forEach {
            removeValues(for: $0)
        }
    }

    func toggleValue(for node: CCFilterNode) {
        if isSelected(node) {
            removeValues(for: node)
        } else {
            setValue(node.value, for: node)
        }
    }

    func isSelected(_ node: CCFilterNode) -> Bool {
        let selected: Bool

        if node is CCMapFilterNode || node is CCRangeFilterNode {
            selected = node.children.contains(where: { isSelected($0) })
        } else {
            selected = !node.children.isEmpty && node.children.allSatisfy { isSelected($0) }
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
        } else if isSelected(node) {
            return [node.title]
        } else {
            return node.children.reduce([]) { $0 + titles(for: $1) }
        }
    }

    func hasSelectedChildren(node: CCFilterNode) -> Bool {
        if isSelected(node) {
            return true
        }

        return node.children.reduce(false) { $0 || hasSelectedChildren(node: $1) }
    }

    func selectedChildren(for node: CCFilterNode) -> [CCFilterNode] {
        if isSelected(node) {
            return [node]
        }

        return node.children.reduce([]) { $0 + selectedChildren(for: $1) }
    }
}
