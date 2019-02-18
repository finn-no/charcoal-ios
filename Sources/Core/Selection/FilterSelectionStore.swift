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

    func value<T: LosslessStringConvertible>(for filter: Filter) -> T? {
        return queryItem(for: filter)?.value.flatMap({ T($0) })
    }

    func clear() {
        queryItems.removeAll()
    }

    private func queryItem(for filter: Filter) -> URLQueryItem? {
        if let value = filter.value {
            return queryItems.first(where: { $0.name == filter.name && $0.value == value })
        } else if filter.hasNoSubfilters {
            return queryItems.first(where: { $0.name == filter.name })
        } else {
            return nil
        }
    }
}

// MARK: - Selection

extension FilterSelectionStore {
    func setValue(from filter: Filter) {
        setValue(filter.value, for: filter)
    }

    func setValue<T: LosslessStringConvertible>(_ value: T?, for filter: Filter) {
        removeValues(for: filter)

        if let value = value {
            let queryItem = URLQueryItem(name: filter.name, value: String(value))
            queryItems.insert(queryItem)
        }
    }

    func removeValues(for filter: Filter) {
        if let queryItem = queryItem(for: filter) {
            queryItems.remove(queryItem)
        }

        filter.children.forEach {
            removeValues(for: $0)
        }
    }

    func toggleValue(for filter: Filter) {
        if isSelected(filter) {
            removeValues(for: filter)
        } else {
            setValue(filter.value, for: filter)
        }
    }

    func isSelected(_ filter: Filter) -> Bool {
        let selected: Bool

        if filter is MapFilter || filter is RangeFilter {
            selected = filter.children.contains(where: { isSelected($0) })
        } else {
            selected = !filter.children.isEmpty && filter.children.allSatisfy { isSelected($0) }
        }

        return queryItem(for: filter) != nil || selected
    }
}

// MARK: - Helpers

extension FilterSelectionStore {
    func queryItems(for filter: Filter) -> [URLQueryItem] {
        if let queryItem = queryItem(for: filter) {
            return [queryItem]
        }

        return filter.children.reduce([]) { $0 + queryItems(for: $1) }
    }

    func titles(for filter: Filter) -> [String] {
        if let rangeFilter = filter as? RangeFilter {
            let lowValue: String? = value(for: rangeFilter.lowValueFilter)
            let highValue: String? = value(for: rangeFilter.highValueFilter)

            if lowValue == nil && highValue == nil {
                return []
            } else {
                return ["\(lowValue ?? "...") - \(highValue ?? "...")"]
            }
        } else if isSelected(filter) {
            return [filter.title]
        } else {
            return filter.children.reduce([]) { $0 + titles(for: $1) }
        }
    }

    func hasSelectedChildren(_ filter: Filter) -> Bool {
        if isSelected(filter) {
            return true
        }

        return filter.children.reduce(false) { $0 || hasSelectedChildren($1) }
    }

    func selectedChildren(for filter: Filter) -> [Filter] {
        if isSelected(filter) {
            return [filter]
        }

        return filter.children.reduce([]) { $0 + selectedChildren(for: $1) }
    }
}
