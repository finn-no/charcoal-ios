//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

class MultiLevelListSelectionFilterInfo: MultiLevelListSelectionFilterInfoType, ParameterBasedFilterInfo {
    struct LookupKey: Hashable {
        let parameterName: String
        let value: String
    }

    let parameterName: String
    private(set) var filters: [MultiLevelListSelectionFilterInfoType]
    let title: String
    let isMultiSelect: Bool
    let results: Int
    let value: String
    private(set) weak var parent: MultiLevelListSelectionFilterInfoType?
    var selectionState: MultiLevelListItemSelectionState
    var hasParent: Bool {
        return parent != nil
    }

    var parentFilterInfo: FilterInfoType? {
        return parent
    }

    init(parameterName: String, title: String, isMultiSelect: Bool = true, results: Int, value: String) {
        self.parameterName = parameterName
        self.title = title
        self.isMultiSelect = isMultiSelect
        self.results = results
        self.value = value
        selectionState = .none
        filters = []
    }

    func setSubLevelFilters(_ subLevels: [MultiLevelListSelectionFilterInfo]) {
        filters = subLevels
        subLevels.forEach({ $0.parent = self })
    }

    private func childFilterHasPartialSelectionState() -> Bool {
        return filters.contains(where: { (filterInfoType) -> Bool in
            if let filterInfo = filterInfoType as? MultiLevelListSelectionFilterInfo {
                return filterInfo.selectionState == .partial
            }
            return false
        })
    }

    private func numberOfChildFilterWithFullSelectionState() -> Int {
        return filters.filter({ (filterInfoType) -> Bool in
            if let filterInfo = filterInfoType as? MultiLevelListSelectionFilterInfo {
                return filterInfo.selectionState == .selected
            }
            return false
        }).count
    }

    func selectionStateOfChildren() -> MultiLevelListItemSelectionState? {
        if childFilterHasPartialSelectionState() {
            return .partial
        } else if filters.count > 0 {
            let childsWithFullSelection = numberOfChildFilterWithFullSelectionState()
            if childsWithFullSelection == filters.count {
                return .selected
            } else if childsWithFullSelection > 0 {
                return .partial
            } else {
                // Use full enum name, so compiler doesn't mistake intent to be the Optional.none (nil)
                return MultiLevelListItemSelectionState.none
            }
        } else {
            return nil
        }
    }
}

extension MultiLevelListSelectionFilterInfo: CustomDebugStringConvertible {
    var debugDescription: String {
        return "<\(type(of: self)): \(Unmanaged.passUnretained(self).toOpaque())> parameter: \(parameterName), title: \(title), subfilters: \(filters.count)"
    }
}

extension MultiLevelListSelectionFilterInfo: Equatable {
    static func == (lhs: MultiLevelListSelectionFilterInfo, rhs: MultiLevelListSelectionFilterInfo) -> Bool {
        return lhs.parameterName == rhs.parameterName && lhs.value == rhs.value && lhs.filters.count == rhs.filters.count
    }
}

extension MultiLevelListSelectionFilterInfo {
    var lookupKey: MultiLevelListSelectionFilterInfo.LookupKey {
        return LookupKey(parameterName: parameterName, value: value)
    }
}
