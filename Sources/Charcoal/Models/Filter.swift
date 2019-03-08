//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class Filter {
    public enum Style {
        case normal
        case context
    }

    public enum Kind {
        case list
        case search
        case inline
        case stepper(config: StepperFilterConfiguration)
        case external
        case range(lowValueFilter: Filter, highValueFilter: Filter, config: RangeFilterConfiguration)
        case map(latitudeFilter: Filter, longitudeFilter: Filter, radiusFilter: Filter, locationNameFilter: Filter)
    }

    public let title: String
    public let key: String
    public let value: String?
    public let style: Style
    public let kind: Kind
    public var numberOfResults: Int
    public var mutuallyExclusiveFilterKeys = Set<String>()

    private(set) var subfilters: [Filter] = []

    // MARK: - Init

    private init(title: String, key: String, value: String? = nil, numberOfResults: Int = 0,
                 kind: Kind = .list, style: Style = .normal) {
        self.title = title
        self.key = key
        self.value = value
        self.numberOfResults = numberOfResults
        self.kind = kind
        self.style = style
    }

    // MARK: - Public methods

    public func subfilter(at index: Int) -> Filter? {
        guard index < subfilters.count else { return nil }
        return subfilters[index]
    }

    public func merge(with other: Filter) {
        for (index, filter) in other.subfilters.enumerated() {
            if let common = subfilters.first(where: { $0 == filter }) {
                common.merge(with: filter)
            } else {
                if index < subfilters.count {
                    subfilters.insert(filter, at: index)
                } else {
                    subfilters.append(filter)
                }
            }
        }
    }
}

extension Filter: Equatable {
    public static func == (lhs: Filter, rhs: Filter) -> Bool {
        let equalKey = lhs.key == rhs.key
        let equalValue = lhs.value == rhs.value
        return equalKey && equalValue
    }
}

// MARK: - Factory

extension Filter {
    public static func list(title: String, key: String, value: String? = nil, numberOfResults: Int = 0,
                            style: Style = .normal, subfilters: [Filter] = []) -> Filter {
        let filter = Filter(
            title: title,
            key: key,
            value: value,
            numberOfResults: numberOfResults,
            kind: .list,
            style: style
        )

        filter.subfilters.append(contentsOf: subfilters)

        return filter
    }

    public static func search(title: String? = nil, key: String) -> Filter {
        let title = title ?? "search_placeholder".localized()
        return Filter(title: title, key: key, value: nil, numberOfResults: 0, kind: .search)
    }

    public static func inline(title: String, key: String, subfilters: [Filter]) -> Filter {
        let filter = Filter(title: title, key: key, value: nil, numberOfResults: 0, kind: .inline)
        filter.subfilters.append(contentsOf: subfilters)
        return filter
    }

    public static func stepper(title: String, key: String,
                               config: StepperFilterConfiguration, style: Style = .normal) -> Filter {
        return Filter(
            title: title,
            key: key,
            value: nil,
            numberOfResults: 0,
            kind: .stepper(config: config),
            style: style
        )
    }

    public static func external(title: String, key: String, value: String?,
                                numberOfResults: Int = 0, style: Style = .normal) -> Filter {
        return Filter(title: title, key: key, value: value, numberOfResults: numberOfResults, kind: .external, style: style)
    }

    public static func range(title: String, key: String, lowValueKey: String, highValueKey: String,
                             config: RangeFilterConfiguration, style: Style = .normal) -> Filter {
        let lowValueFilter = Filter(title: "", key: lowValueKey, kind: .list)
        let highValueFilter = Filter(title: "", key: highValueKey, kind: .list)
        let kind = Kind.range(lowValueFilter: lowValueFilter, highValueFilter: highValueFilter, config: config)
        let filter = Filter(title: title, key: key, value: nil, numberOfResults: 0, kind: kind, style: style)

        filter.subfilters.append(contentsOf: [lowValueFilter, highValueFilter])

        return filter
    }

    public static func map(title: String? = nil, key: String, latitudeKey: String,
                           longitudeKey: String, radiusKey: String, locationKey: String) -> Filter {
        let title = title ?? "map_filter_title".localized()
        let latitudeFilter = Filter(title: "", key: latitudeKey, kind: .list)
        let longitudeFilter = Filter(title: "", key: longitudeKey, kind: .list)
        let radiusFilter = Filter(title: "", key: radiusKey, kind: .list)
        let locationNameFilter = Filter(title: "", key: locationKey, kind: .list)

        let kind = Kind.map(
            latitudeFilter: latitudeFilter,
            longitudeFilter: longitudeFilter,
            radiusFilter: radiusFilter,
            locationNameFilter: locationNameFilter
        )

        let filter = Filter(title: title, key: key, value: nil, numberOfResults: 0, kind: kind, style: .normal)
        filter.subfilters.append(contentsOf: [latitudeFilter, longitudeFilter, radiusFilter, locationNameFilter])

        return filter
    }
}
