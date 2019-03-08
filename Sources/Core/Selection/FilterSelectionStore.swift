//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

protocol FilterSelectionStoreDelegate: class {
    func filterSelectionStoreDidChange(_ selectionStore: FilterSelectionStore)
}

final class FilterSelectionStore {

    // MARK: - Internal properties

    weak var delegate: FilterSelectionStoreDelegate?

    // MARK: - Private properties

    private var queryItems: Set<URLQueryItem>

    // MARK: - Init

    init(queryItems: Set<URLQueryItem> = []) {
        self.queryItems = queryItems
    }

    func set(selection: Set<URLQueryItem>) {
        queryItems = selection
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
            return queryItems.first(where: { $0.name == filter.key && $0.value == value })
        } else if filter.subfilters.isEmpty {
            return queryItems.first(where: { $0.name == filter.key })
        } else {
            return nil
        }
    }
}

// MARK: - Selection

extension FilterSelectionStore {
    func setValue(from filter: Filter) {
        _setValue(filter.value, for: filter)
        delegate?.filterSelectionStoreDidChange(self)
    }

    func setValue<T: LosslessStringConvertible>(_ value: T?, for filter: Filter) {
        _setValue(value, for: filter)
        delegate?.filterSelectionStoreDidChange(self)
    }

    func removeValues(for filter: Filter) {
        _removeValues(for: filter)
        delegate?.filterSelectionStoreDidChange(self)
    }

    func toggleValue(for filter: Filter) {
        if isSelected(filter) {
            _removeValues(for: filter)
        } else {
            _setValue(filter.value, for: filter)
        }

        delegate?.filterSelectionStoreDidChange(self)
    }

    func isSelected(_ filter: Filter) -> Bool {
        let selected: Bool

        switch filter.kind {
        case .map, .range:
            selected = filter.subfilters.contains(where: { isSelected($0) })
        default:
            selected = !filter.subfilters.isEmpty && filter.subfilters.allSatisfy { isSelected($0) }
        }

        return queryItem(for: filter) != nil || selected
    }
}

private extension FilterSelectionStore {
    func _setValue<T: LosslessStringConvertible>(_ value: T?, for filter: Filter) {
        _removeValues(for: filter)

        if let value = value {
            let queryItem = URLQueryItem(name: filter.key, value: String(value))
            queryItems.insert(queryItem)
        }
    }

    func _removeValues(for filter: Filter) {
        if let queryItem = queryItem(for: filter) {
            queryItems.remove(queryItem)
        }

        filter.subfilters.forEach {
            _removeValues(for: $0)
        }
    }
}

// MARK: - Helpers

extension FilterSelectionStore {
    func queryItems(for filter: Filter) -> [URLQueryItem] {
        if let queryItem = queryItem(for: filter) {
            return [queryItem]
        }

        return filter.subfilters.reduce([]) { $0 + queryItems(for: $1) }
    }

    func titles(for filter: Filter) -> [String] {
        switch filter.kind {
        case let .range(lowValueFilter, highValueFilter, _):
            let lowValue: String? = value(for: lowValueFilter)
            let highValue: String? = value(for: highValueFilter)

            if lowValue == nil && highValue == nil {
                return []
            } else {
                return ["\(lowValue ?? "...") - \(highValue ?? "...")"]
            }
        case .stepper:
            return value(for: filter).map({ [$0] }) ?? []
        case let .map(_, _, radiusFilter, _):
            if let radius: Int = value(for: radiusFilter) {
                let formatter = MapDistanceValueFormatter()
                return [formatter.title(for: radius)]
            } else {
                fallthrough
            }
        default:
            if isSelected(filter) {
                return [filter.title]
            } else {
                return filter.subfilters.reduce([]) { $0 + titles(for: $1) }
            }
        }
    }

    func isValid(_ filter: Filter) -> Bool {
        switch filter.kind {
        case let .range(lowValueFilter, highValueFilter, _):
            let lowValue: Int? = value(for: lowValueFilter)
            let highValue: Int? = value(for: highValueFilter)

            if let lowValue = lowValue, let highValue = highValue {
                return lowValue <= highValue
            } else {
                return true
            }
        default:
            return true
        }
    }

    func hasSelectedSubfilters(for filter: Filter, where predicate: ((Filter) -> Bool) = { _ in true }) -> Bool {
        if isSelected(filter) && predicate(filter) {
            return true
        }

        return filter.subfilters.reduce(false) { $0 || hasSelectedSubfilters(for: $1, where: predicate) }
    }

    func selectedSubfilters(for filter: Filter, where predicate: ((Filter) -> Bool) = { _ in true }) -> [Filter] {
        if isSelected(filter) && predicate(filter) {
            return [filter]
        }

        return filter.subfilters.reduce([]) { $0 + selectedSubfilters(for: $1, where: predicate) }
    }
}
