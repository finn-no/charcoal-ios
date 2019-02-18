//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

final class FilterSelectionStore {
    private var queryItems: Set<URLQueryItem>

    // MARK: - Init

    init(queryItems: Set<URLQueryItem> = []) {
        self.queryItems = queryItems
    }

    // MARK: - Values

    func value<T: LosslessStringConvertible>(for node: Filter) -> T? {
        return queryItem(for: node)?.value.flatMap({ T($0) })
    }

    func clear() {
        queryItems.removeAll()
    }

    private func queryItem(for node: Filter) -> URLQueryItem? {
        if let value = node.value {
            return queryItems.first(where: { $0.name == node.name && $0.value == value })
        } else if node.isLeafNode {
            return queryItems.first(where: { $0.name == node.name })
        } else {
            return nil
        }
    }
}

// MARK: - Selection

extension FilterSelectionStore {
    func setValue(from node: Filter) {
        setValue(node.value, for: node)
    }

    func setValue<T: LosslessStringConvertible>(_ value: T?, for node: Filter) {
        removeValues(for: node)

        if let value = value {
            let queryItem = URLQueryItem(name: node.name, value: String(value))
            queryItems.insert(queryItem)
        }
    }

    func removeValues(for node: Filter) {
        if let queryItem = queryItem(for: node) {
            queryItems.remove(queryItem)
        }

        node.children.forEach {
            removeValues(for: $0)
        }
    }

    func toggleValue(for node: Filter) {
        if isSelected(node) {
            removeValues(for: node)
        } else {
            setValue(node.value, for: node)
        }
    }

    func isSelected(_ node: Filter) -> Bool {
        let selected: Bool

        if node is MapFilter || node is RangeFilterNode {
            selected = node.children.contains(where: { isSelected($0) })
        } else {
            selected = !node.children.isEmpty && node.children.allSatisfy { isSelected($0) }
        }

        return queryItem(for: node) != nil || selected
    }
}

// MARK: - Helpers

extension FilterSelectionStore {
    func queryItems(for node: Filter) -> [URLQueryItem] {
        if let queryItem = queryItem(for: node) {
            return [queryItem]
        }

        return node.children.reduce([]) { $0 + queryItems(for: $1) }
    }

    func titles(for node: Filter) -> [String] {
        if let rangeNode = node as? RangeFilterNode {
            let lowValue: String? = value(for: rangeNode.lowValueNode)
            let highValue: String? = value(for: rangeNode.highValueNode)

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

    func hasSelectedChildren(node: Filter) -> Bool {
        if isSelected(node) {
            return true
        }

        return node.children.reduce(false) { $0 || hasSelectedChildren(node: $1) }
    }

    func selectedChildren(for node: Filter) -> [Filter] {
        if isSelected(node) {
            return [node]
        }

        return node.children.reduce([]) { $0 + selectedChildren(for: $1) }
    }
}
