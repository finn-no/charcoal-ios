//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class Filter {
    public enum Style {
        case normal
        case context
    }

    public enum Kind: Equatable {
        case list
        case grid
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

    public init(kind: Kind, title: String, key: String, value: String? = nil, numberOfResults: Int = 0,
                style: Style = .normal, subfilters: [Filter] = []) {
        self.title = title
        self.key = key
        self.value = value
        self.numberOfResults = numberOfResults
        self.kind = kind
        self.style = style
        self.subfilters.append(contentsOf: subfilters)
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
        return Filter(
            kind: .list,
            title: title,
            key: key,
            value: value,
            numberOfResults: numberOfResults,
            style: style,
            subfilters: subfilters
        )
    }

    public static func search(title: String? = nil, key: String) -> Filter {
        let title = title ?? "searchPlaceholder".localized()
        return Filter(kind: .search, title: title, key: key, value: nil, numberOfResults: 0)
    }

    public static func inline(title: String, key: String, subfilters: [Filter]) -> Filter {
        return Filter(kind: .inline, title: title, key: key, value: nil, numberOfResults: 0, subfilters: subfilters)
    }

    public static func stepper(title: String, key: String,
                               config: StepperFilterConfiguration, style: Style = .normal) -> Filter {
        return Filter(
            kind: .stepper(config: config),
            title: title,
            key: key,
            value: nil,
            numberOfResults: 0,
            style: style
        )
    }

    public static func external(title: String, key: String, value: String?,
                                numberOfResults: Int = 0, style: Style = .normal) -> Filter {
        return Filter(kind: .external, title: title, key: key, value: value, numberOfResults: numberOfResults, style: style)
    }

    public static func range(title: String, key: String, lowValueKey: String, highValueKey: String,
                             config: RangeFilterConfiguration, style: Style = .normal) -> Filter {
        let lowValueFilter = Filter(kind: .list, title: "", key: lowValueKey)
        let highValueFilter = Filter(kind: .list, title: "", key: highValueKey)
        let kind = Kind.range(lowValueFilter: lowValueFilter, highValueFilter: highValueFilter, config: config)
        let subfilters = [lowValueFilter, highValueFilter]

        return Filter(kind: kind, title: title, key: key, value: nil, numberOfResults: 0, style: style, subfilters: subfilters)
    }

    public static func map(title: String? = nil, key: String, latitudeKey: String,
                           longitudeKey: String, radiusKey: String, locationKey: String) -> Filter {
        let title = title ?? "map.title".localized()
        let latitudeFilter = Filter(kind: .list, title: "", key: latitudeKey)
        let longitudeFilter = Filter(kind: .list, title: "", key: longitudeKey)
        let radiusFilter = Filter(kind: .list, title: "", key: radiusKey)
        let locationNameFilter = Filter(kind: .list, title: "", key: locationKey)

        let kind = Kind.map(
            latitudeFilter: latitudeFilter,
            longitudeFilter: longitudeFilter,
            radiusFilter: radiusFilter,
            locationNameFilter: locationNameFilter
        )

        let subfilters = [latitudeFilter, longitudeFilter, radiusFilter, locationNameFilter]

        return Filter(kind: kind, title: title, key: key, value: nil, numberOfResults: 0, style: .normal, subfilters: subfilters)
    }
}

// MARK: - Helpers

extension Filter {
    var formattedNumberOfResults: String {
        return NumberFormatter.decimalFormatter.string(from: numberOfResults) ?? ""
    }
}
