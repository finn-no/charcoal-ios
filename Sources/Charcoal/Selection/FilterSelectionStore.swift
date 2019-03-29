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

    @discardableResult
    func toggleValue(for filter: Filter) -> Bool {
        let isSelected = self.isSelected(filter)

        _removeValues(for: filter)

        if !isSelected {
            _setValue(filter.value, for: filter)
        }

        delegate?.filterSelectionStoreDidChange(self)

        return !isSelected
    }

    func isSelected(_ filter: Filter) -> Bool {
        switch filter.kind {
        case let .map(_, _, radiusFilter, _):
            return isSelected(radiusFilter)
        case .range:
            return filter.subfilters.contains(where: { isSelected($0) })
        default:
            return queryItem(for: filter) != nil
        }
    }
}

private extension FilterSelectionStore {
    func _setValue<T: LosslessStringConvertible>(_ value: T?, for filter: Filter) {
        _removeValues(for: filter)

        if let value = value.map(String.init), value != "" {
            let queryItem = URLQueryItem(name: filter.key, value: value)
            queryItems.insert(queryItem)
        }
    }

    func _removeValues(for filter: Filter, withSubfilters: Bool = true) {
        if let queryItem = queryItem(for: filter) {
            queryItems.remove(queryItem)
        }

        if withSubfilters {
            filter.subfilters.forEach {
                _removeValues(for: $0)
            }
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

    func titles(for filter: Filter) -> [SelectionTitle] {
        switch filter.kind {
        case let .range(lowValueFilter, highValueFilter, config):
            let formatter = RangeFilterValueFormatter(unit: config.unit)
            let suffix = config.unit.value.isEmpty ? "" : " \(config.unit.value)"
            let accessibilitySuffix = " " + config.unit.accessibilityValue

            func formattedValue(for filter: Filter) -> String? {
                return (self.value(for: filter) as Int?).flatMap({ formatter.string(from: $0) })
            }

            let value: String?

            switch (formattedValue(for: lowValueFilter), formattedValue(for: highValueFilter)) {
            case (.none, .none):
                value = nil
            case let (.some(lowValue), .none):
                value = "\(config.unit.fromValueText) \(lowValue)"
            case let (.none, .some(highValue)):
                value = "\(config.unit.tilValueText) \(highValue)"
            case let (.some(lowValue), .some(highValue)):
                value = "\(lowValue) - \(highValue)"
            }

            if let value = value {
                let title = SelectionTitle(
                    value: "\(value)\(suffix)",
                    accessibilityLabel: "\(value.accessibilityLabelForRanges)\(accessibilitySuffix)"
                )
                return [title]
            } else {
                return []
            }
        case .stepper:
            if let lowValue: Int = value(for: filter) {
                return [SelectionTitle(value: "\(lowValue)+")]
            } else {
                return []
            }
        case let .map(_, _, radiusFilter, _):
            if let radius: Int = value(for: radiusFilter) {
                let value = MapDistanceValueFormatter().title(for: radius)
                return [SelectionTitle(value: value)]
            } else {
                return []
            }
        default:
            if isSelected(filter) {
                return [SelectionTitle(value: filter.title)]
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

    func syncSelection(with filterContainer: FilterContainer) {
        let keys = syncSelection(with: filterContainer.rootFilter)
        queryItems = queryItems.filter({ keys.contains($0.name) })
    }

    /**
     Cleans up selected values based on filter hierarchy (e.g. deselect filters with selected subfilters).
     - Parameter filter: The root filter.
     - Returns: Keys of all processed filters.
     **/
    private func syncSelection(with filter: Filter) -> Set<String> {
        var isSelected = self.isSelected(filter)
        var keys = Set([filter.key])

        for subfilter in filter.subfilters {
            if isSelected && hasSelectedSubfilters(for: subfilter) {
                _removeValues(for: filter, withSubfilters: false)
                isSelected = false
            }

            let subfilterKeys = syncSelection(with: subfilter)
            keys = keys.union(subfilterKeys)
        }

        return keys
    }
}

private extension String {
    var accessibilityLabelForRanges: String {
        if contains("-") {
            let formattedAccessibilityLabel = replacingOccurrences(of: "-", with: "til".localized())
            return "from".localized() + " " + formattedAccessibilityLabel
        } else {
            return self
        }
    }
}
