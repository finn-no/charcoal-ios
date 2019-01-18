//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

class FilterSelectionData {
    private(set) var selectionValues: [String: [String]]

    init(selectionValues: [String: [String]]) {
        self.selectionValues = selectionValues
    }
}

extension FilterSelectionData {
    func setSelectionValues(_ values: [String], for key: String) {
        selectionValues[key] = values
    }

    func setSelectionValue(_ value: String, for key: String) {
        setSelectionValues([value], for: key)
    }

    func addSelectionValue(_ value: String, for key: String) {
        var values: [String]
        if let previousValues = selectionValues[key] {
            values = previousValues
        } else {
            values = []
        }
        values.append(value)
        setSelectionValues(values, for: key)
    }

    func removeSelectionValue(_ value: String, for key: String) {
        if let previousValues = selectionValues[key] {
            setSelectionValues(previousValues.filter({ $0 != value }), for: key)
        }
    }

    func removeSelectionValues(_ key: String) {
        selectionValues.removeValue(forKey: key)
    }

    func selectionValues(for key: String) -> [String] {
        return selectionValues[key] ?? []
    }

    func filterParameter(for filterInfo: FilterInfoType) -> String? {
        if let filter = filterInfo as? ParameterBasedFilterInfo {
            return filter.parameterName
        }
        return nil
    }

    func setStringValue(_ value: String, for key: String) {
        setSelectionValue(value, for: key)
    }

    func updateSelectionStateForAncestors(of multiLevelFilter: MultiLevelListSelectionFilterInfo) {
        guard let parent = multiLevelFilter.parent as? MultiLevelListSelectionFilterInfo else {
            return
        }
        if let selectionStateOfChildren = parent.selectionStateOfChildren() {
            parent.selectionState = selectionStateOfChildren
            if selectionStateOfChildren == .none {
                removeValue(parent.value, for: parent)
            }
        }
        updateSelectionStateForAncestors(of: parent)
    }

    func isAncestor(_ ancestor: MultiLevelListSelectionFilterInfo, to multiLevelFilter: MultiLevelListSelectionFilterInfoType?) -> Bool {
        guard let multiLevelFilter = multiLevelFilter as? MultiLevelListSelectionFilterInfo else {
            return false
        }
        guard let multiLevelFilterParent = multiLevelFilter.parent as? MultiLevelListSelectionFilterInfo else {
            return false
        }
        if multiLevelFilterParent === ancestor {
            return true
        }
        return isAncestor(ancestor, to: multiLevelFilterParent)
    }

    func removeValueAndValueForChildren(for filterInfo: MultiLevelListSelectionFilterInfoType, updateSelectionStateForParent: Bool) {
        for childFilter in filterInfo.filters {
            removeValueAndValueForChildren(for: childFilter, updateSelectionStateForParent: false)
            if let filterKey = filterParameter(for: childFilter) {
                removeSelectionValue(childFilter.value, for: filterKey)
            }
        }

        if let multiLevelFilter = filterInfo as? MultiLevelListSelectionFilterInfo {
            multiLevelFilter.selectionState = .none
            removeValue(multiLevelFilter.value, for: multiLevelFilter)

            if updateSelectionStateForParent {
                updateSelectionStateForAncestors(of: multiLevelFilter)
            }
        }
    }

    func removeValue(_ value: String, for filterInfo: FilterInfoType) {
        guard let filterKey = filterParameter(for: filterInfo) else {
            return
        }
        removeSelectionValue(value, for: filterKey)

        if let multiLevelFilter = filterInfo as? MultiLevelListSelectionFilterInfo {
            multiLevelFilter.selectionState = .none
            if let selectionStateOfChildren = multiLevelFilter.selectionStateOfChildren() {
                multiLevelFilter.selectionState = selectionStateOfChildren
            }

            updateSelectionStateForAncestors(of: multiLevelFilter)
        }
    }

    func addValue(_ value: String, for filterInfo: FilterInfoType) {
        guard let filterKey = filterParameter(for: filterInfo) else {
            return
        }
        addSelectionValue(value, for: filterKey)

        if let multiLevelFilter = filterInfo as? MultiLevelListSelectionFilterInfo {
            multiLevelFilter.selectionState = .selected
            if let parent = multiLevelFilter.parent as? MultiLevelListSelectionFilterInfo, parent.hasParent, parent.selectionState == .none {
                addValue(parent.value, for: parent)
            }
            updateSelectionStateForAncestors(of: multiLevelFilter)
        }
    }
}
