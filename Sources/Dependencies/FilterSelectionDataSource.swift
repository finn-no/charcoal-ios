//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterSelectionDataSource: AnyObject {
    func value(for filterInfo: FilterInfoType) -> FilterSelectionValue?
    func setValue(_ filterSelectionValue: FilterSelectionValue?, for filterInfo: FilterInfoType)
}

public class KeyedFilterInfoSelectionDataSource: NSObject {
    private var selectionValues: [String: [String]]

    public init(queryItems: [URLQueryItem]) {
        var selectionValues = [String: [String]]()
        for qi in queryItems {
            guard let value = qi.value else {
                continue
            }
            if let values = selectionValues[qi.name] {
                selectionValues[qi.name] = values + [value]
            } else {
                selectionValues[qi.name] = [value]
            }
        }
        self.selectionValues = selectionValues
    }

    public convenience override init() {
        self.init(queryItems: [URLQueryItem]())
    }

    public override var description: String {
        return selectionValues.compactMap({ (keyAndValues) -> String? in
            return keyAndValues.value.map({ keyAndValues.key + "=" + $0 })
                .joined(separator: "&")
        }).joined(separator: "&")
    }
}

private extension KeyedFilterInfoSelectionDataSource {
    func setSelectionValues(_ values: [String], for key: String) {
        selectionValues[key] = values
    }

    func setSelectionValue(_ value: String, for key: String) {
        setSelectionValues([value], for: key)
    }

    func removeSelectionValue(_ key: String) {
        selectionValues.removeValue(forKey: key)
    }

    func selectionValues(for name: String) -> [String] {
        return selectionValues[name] ?? []
    }

    func filterKey(for filterInfo: FilterInfoType) -> String? {
        if let keyedFilterInfo = filterInfo as? KeyedFilterInfo {
            return keyedFilterInfo.key.rawValue
        }
        return nil
    }

    func setStringValue(_ value: String?, for key: String) {
        if let value = value, !value.isEmpty {
            setSelectionValue(value, for: key)
        } else {
            removeSelectionValue(key)
        }
    }

    func setFilterSelectionValue(_ value: FilterSelectionValue, for key: String) {
        switch value {
        case let .singleSelection(value):
            setStringValue(value, for: key)
        case let .multipleSelection(values):
            setSelectionValues(values, for: key)
        case let .rangeSelection(lowValue, highValue):
            setStringValue(lowValue?.description ?? "", for: key + "_from")
            setStringValue(highValue?.description ?? "", for: key + "_to")
        }
    }

    func intOrNil(from value: String?) -> Int? {
        guard let value = value else {
            return nil
        }
        return Int(value)
    }
}

extension KeyedFilterInfoSelectionDataSource: FilterSelectionDataSource {
    public func value(for filterInfo: FilterInfoType) -> FilterSelectionValue? {
        guard let filterKey = filterKey(for: filterInfo) else {
            return nil
        }
        if filterInfo is RangeFilterInfoType {
            let low = selectionValues(for: filterKey + "_from").first
            let high = selectionValues(for: filterKey + "_to").first
            return .rangeSelection(lowValue: intOrNil(from: low), highValue: intOrNil(from: high))
        } else {
            let values = selectionValues(for: filterKey)
            if values.count < 1 {
                return nil
            }
            if filterInfo is ListItem {
                return .multipleSelection(values: values)
            } else {
                if let value = values.first {
                    return .singleSelection(value: value)
                }
            }
            return nil
        }
    }

    public func setValue(_ filterSelectionValue: FilterSelectionValue?, for filterInfo: FilterInfoType) {
        guard let filterKey = filterKey(for: filterInfo) else {
            return
        }
        if let filterSelectionValue = filterSelectionValue {
            setFilterSelectionValue(filterSelectionValue, for: filterKey)
        } else {
            removeSelectionValue(filterKey)
        }
    }
}
