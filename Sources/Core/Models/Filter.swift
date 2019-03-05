//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

final class Filter {
    enum Style {
        case normal
        case context
    }

    enum Kind {
        case list
        case search
        case inline
        case stepper
        case external
        case range(lowValueFilter: Filter, highValueFilter: Filter)
        case map(latitudeFilter: Filter, longitudeFilter: Filter, radiusFilter: Filter, locationNameFilter: Filter)
    }

    let title: String
    let key: String
    let value: String?
    var numberOfResults: Int
    let style: Style
    let kind: Kind

    var subfilters: [Filter] = []
    private(set) weak var parent: Filter?

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

    private func add(subfilter: Filter, at index: Int? = nil) {
        if let index = index {
            subfilters.insert(subfilter, at: index)
        } else {
            subfilters.append(subfilter)
        }
        subfilter.parent = self
    }

    func subfilter(at index: Int) -> Filter? {
        guard index < subfilters.count else { return nil }
        return subfilters[index]
    }
}

extension Filter: Equatable {
    static func == (lhs: Filter, rhs: Filter) -> Bool {
        let equalKey = lhs.key == rhs.key
        guard let lhsValue = lhs.value, let rhsValue = rhs.value else { return equalKey }
        let equalValue = lhsValue == rhsValue
        return equalKey && equalValue
    }
}

// MARK: - Factory

extension Filter {
    static func list(title: String, key: String, value: String? = nil, numberOfResults: Int = 0,
                     style: Style = .normal, subfilters: [Filter] = []) -> Filter {
        let filter = Filter(
            title: title,
            key: key,
            value: value,
            numberOfResults: numberOfResults,
            kind: .list,
            style: style
        )

        subfilters.forEach {
            filter.add(subfilter: $0)
        }

        return filter
    }

    static func search(title: String, key: String) -> Filter {
        return Filter(title: title, key: key, value: nil, numberOfResults: 0, kind: .search)
    }

    static func inline(title: String, key: String, subfilters: [Filter]) -> Filter {
        let filter = Filter(title: title, key: key, value: nil, numberOfResults: 0, kind: .inline)

        subfilters.forEach {
            filter.add(subfilter: $0)
        }

        return filter
    }

    static func stepper(title: String, key: String, style: Style = .normal) -> Filter {
        return Filter(title: title, key: key, value: nil, numberOfResults: 0, kind: .stepper, style: style)
    }

    static func external(title: String, key: String, value: String?,
                         numberOfResults: Int = 0, style: Style = .normal) -> Filter {
        return Filter(title: title, key: key, value: value, numberOfResults: numberOfResults, kind: .external, style: style)
    }

    static func range(title: String, key: String, lowValueKey: String,
                      highValueKey: String, style: Style = .normal) -> Filter {
        let lowValueFilter = Filter(title: "", key: lowValueKey, kind: .list)
        let highValueFilter = Filter(title: "", key: highValueKey, kind: .list)
        let kind = Kind.range(lowValueFilter: lowValueFilter, highValueFilter: highValueFilter)
        let filter = Filter(title: title, key: key, value: nil, numberOfResults: 0, kind: kind, style: style)

        filter.add(subfilter: lowValueFilter)
        filter.add(subfilter: highValueFilter)

        return filter
    }

    static func map(title: String, key: String, latitudeKey: String,
                    longitudeKey: String, radiusKey: String, locationKey: String) -> Filter {
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

        filter.add(subfilter: latitudeFilter)
        filter.add(subfilter: longitudeFilter)
        filter.add(subfilter: radiusFilter)
        filter.add(subfilter: locationNameFilter)

        return filter
    }
}
