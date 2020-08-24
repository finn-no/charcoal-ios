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
        case freeText
        case standard
        case grid
        case stepper(config: StepperFilterConfiguration)
        case external
        case range(lowValueFilter: Filter, highValueFilter: Filter, config: RangeFilterConfiguration)
        case map(latitudeFilter: Filter, longitudeFilter: Filter, radiusFilter: Filter,
                 locationNameFilter: Filter, bboxFilter: Filter?, polygonFilter: Filter?)
    }

    public let title: String
    public let key: String
    public let value: String?
    public let style: Style
    public let kind: Kind
    public var numberOfResults: Int
    public var mutuallyExclusiveFilterKeys = Set<String>()

    public var parent: Filter?
    public fileprivate(set) var subfilters: [Filter] = []

    // MARK: - Init

    public init(kind: Kind = .standard, title: String, key: String, value: String? = nil, numberOfResults: Int = 0,
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

    public func mergeSubfilters(with other: Filter) {
        subfilters.merge(with: other.subfilters)
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
    public static func freeText(title: String? = nil, key: String) -> Filter {
        let title = title ?? "searchPlaceholder".localized()
        return Filter(kind: .freeText, title: title, key: key, value: nil, numberOfResults: 0)
    }

    public static func inline(title: String, key: String, subfilters: [Filter]) -> Filter {
        return Filter(title: title, key: key, value: nil, numberOfResults: 0, subfilters: subfilters)
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
        let lowValueFilter = Filter(title: "", key: lowValueKey)
        let highValueFilter = Filter(title: "", key: highValueKey)
        let kind = Kind.range(lowValueFilter: lowValueFilter, highValueFilter: highValueFilter, config: config)
        let subfilters = [lowValueFilter, highValueFilter]

        return Filter(kind: kind, title: title, key: key, value: nil, numberOfResults: 0, style: style, subfilters: subfilters)
    }

    public static func map(title: String? = nil, key: String, latitudeKey: String,
                           longitudeKey: String, radiusKey: String, locationKey: String,
                           bboxKey: String?, polygonKey: String?) -> Filter {
        let title = title ?? "map.title".localized()
        let latitudeFilter = Filter(title: "", key: latitudeKey)
        let longitudeFilter = Filter(title: "", key: longitudeKey)
        let radiusFilter = Filter(title: "", key: radiusKey)
        let locationNameFilter = Filter(title: "", key: locationKey)

        var subfilters = [latitudeFilter, longitudeFilter, radiusFilter, locationNameFilter]

        var bboxFilter: Filter?
        var polygonFilter: Filter?

        if let bboxKey = bboxKey,
            let polygonKey = polygonKey {
            bboxFilter = Filter(title: "", key: bboxKey)
            polygonFilter = Filter(title: "", key: polygonKey)
            subfilters.append(contentsOf: [bboxFilter!, polygonFilter!])
        }

        let kind = Kind.map(
            latitudeFilter: latitudeFilter,
            longitudeFilter: longitudeFilter,
            radiusFilter: radiusFilter,
            locationNameFilter: locationNameFilter,
            bboxFilter: bboxFilter,
            polygonFilter: polygonFilter
        )

        return Filter(kind: kind, title: title, key: key, value: nil, numberOfResults: 0,
                      style: .normal, subfilters: subfilters)
    }
}

// MARK: - Helpers

extension Array where Element == Filter {
    mutating func merge(with filters: [Filter]) {
        for (index, filter) in filters.enumerated() {
            if let common = first(where: { $0 == filter }) {
                common.subfilters.merge(with: filter.subfilters)
            } else {
                if index < count {
                    insert(filter, at: index)
                } else {
                    append(filter)
                }
            }
        }
    }
}
