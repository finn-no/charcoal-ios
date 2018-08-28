//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterSelectionDataSource: AnyObject {
    func value(for filterInfo: FilterInfoType) -> FilterSelectionValue?
    func setValue(_ filterSelectionValue: FilterSelectionValue, for filterInfo: FilterInfoType)
}

public class QueryItemBasedFilterSelectionDataSource: NSObject {
    private var queryItems: [URLQueryItem]

    init(queryItems: [URLQueryItem]) {
        self.queryItems = queryItems
    }
}

private extension QueryItemBasedFilterSelectionDataSource {
    func queryIndex(of queryName: String) -> Int? {
        return queryItems.index(where: { (_) -> Bool in
            return queryName == queryName
        })
    }

    func setQueryItemValues(_ values: [String], for queryName: String) {
        let otherQueryItems = queryItems.filter { (qi) -> Bool in
            return qi.name != queryName
        }
        var newValues = [URLQueryItem]()
        for value in values {
            newValues.append(URLQueryItem(name: queryName, value: value))
        }
        queryItems = otherQueryItems + newValues
    }

    func setQueryItemValue(_ value: String, for queryName: String) {
        setQueryItemValues([value], for: queryName)
    }

    func removeQueryItems(_ queryName: String) {
        setQueryItemValues([], for: queryName)
    }

    func queryItems(for name: String) -> [URLQueryItem] {
        let matchingItems = queryItems.filter { (qi) -> Bool in
            return qi.name == name
        }
        return matchingItems
    }

    func queryName(for filterInfo: FilterInfoType) -> String? {
        if let keyedFilterInfo = filterInfo as? KeyedFilterInfo {
            return keyedFilterInfo.key.rawValue
        }
        return nil
    }

    func setStringValue(_ value: String?, for queryName: String) {
        if let value = value, !value.isEmpty {
            setQueryItemValue(value, for: queryName)
        } else {
            removeQueryItems(queryName)
        }
    }

    func setFilterSelectionValue(_ value: FilterSelectionValue, for queryName: String) {
        switch value {
        case let .singleSelection(value):
            setStringValue(value, for: queryName)
        case let .multipleSelection(values):
            let value = values.joined(separator: ",")
            setStringValue(value, for: queryName)
        case let .rangeSelection(lowValue, highValue):
            setStringValue(lowValue?.description ?? "", for: queryName + "_from")
            setStringValue(highValue?.description ?? "", for: queryName + "_to")
        }
    }

    func intOrNil(from value: String?) -> Int? {
        guard let value = value else {
            return nil
        }
        return Int(value)
    }
}

extension QueryItemBasedFilterSelectionDataSource: FilterSelectionDataSource {
    public func value(for filterInfo: FilterInfoType) -> FilterSelectionValue? {
        guard let queryName = queryName(for: filterInfo) else {
            return nil
        }
        if filterInfo is RangeFilterInfoType {
            let low = queryItems(for: queryName + "_from").first?.value
            let high = queryItems(for: queryName + "_to").first?.value
            return .rangeSelection(lowValue: intOrNil(from: low), highValue: intOrNil(from: high))
        } else {
            if let value = queryItems(for: queryName).first?.value {
                if filterInfo is ListItem {
                    let splittedValues = value.split(separator: ",")
                    return .multipleSelection(values: splittedValues.map({ return String($0) }))
                } else {
                    return .singleSelection(value: value)
                }
            } else {
                return nil
            }
        }
    }

    public func setValue(_ filterSelectionValue: FilterSelectionValue, for filterInfo: FilterInfoType) {
        guard let queryName = queryName(for: filterInfo) else {
            return
        }
        setFilterSelectionValue(filterSelectionValue, for: queryName)
    }
}
