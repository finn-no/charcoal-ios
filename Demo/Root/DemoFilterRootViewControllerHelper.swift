//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit

struct DemoPreferenceValue: PreferenceValue {
    let name: String
    let isSelected: Bool = false
}

struct DemoPreferenceInfo: PreferenceInfo {
    let name: String
    let values: [PreferenceValue]
}

struct DemoFilterInfo: FilterInfo {
    let name: String
    let selectedValues: [String]
}

struct DemoFreeSearchFilterInfo: FreeSearchFilterInfo {
    var currentSearchQuery: String?
    var searchQueryPlaceholder: String
    var name: String
    var selectedValues: [String]
}

struct DemoPreferenceFilterInfo: PreferenceFilterInfo {
    var preferences: [PreferenceInfo]
    var name: String
    var selectedValues: [String]
}

struct DemoMultilevelFilterInfo: MultiLevelFilterInfo {
    var level: Int

    var filters: [MultiLevelFilterInfo]

    var name: String

    var selectedValues: [String]

    let isMultiSelect: Bool = true
}

class DemoFilterService: FilterService {
    var filterComponents: [FilterComponent] {
        let freeSearchFilterInfo = DemoFreeSearchFilterInfo(currentSearchQuery: nil, searchQueryPlaceholder: "Ord i annonsen", name: "freesearch", selectedValues: [])
        let preferencesFilterInfo = DemoPreferenceFilterInfo(preferences: DemoFilterService.preferenceFilters, name: "preferences", selectedValues: [])
        let areaFilterInfo = DemoMultilevelFilterInfo(level: 0, filters: [
            DemoMultilevelFilterInfo(level: 1, filters: [
                DemoMultilevelFilterInfo(level: 2, filters: [], name: "Alle", selectedValues: []),
            ], name: "Oslo", selectedValues: []),
            DemoMultilevelFilterInfo(level: 1, filters: [], name: "Østfold", selectedValues: []),
        ], name: "Område", selectedValues: ["Oslo Øst"])

        return [
            FreeSearchFilterComponent(filterInfo: freeSearchFilterInfo),
            PreferenceFilterComponent(filterInfo: preferencesFilterInfo),
            MultiLevelFilterComponent(filterInfo: DemoMultilevelFilterInfo(level: 0, filters: [], name: "Merke", selectedValues: ["Toyota"])),
            MultiLevelFilterComponent(filterInfo: DemoMultilevelFilterInfo(level: 0, filters: [], name: "Årsmodell", selectedValues: ["2000 - 2017"])),
            MultiLevelFilterComponent(filterInfo: DemoMultilevelFilterInfo(level: 0, filters: [], name: "Kilometerstand", selectedValues: [])),
            MultiLevelFilterComponent(filterInfo: DemoMultilevelFilterInfo(level: 0, filters: [], name: "Pris", selectedValues: [])),
            MultiLevelFilterComponent(filterInfo: areaFilterInfo),
            MultiLevelFilterComponent(filterInfo: DemoMultilevelFilterInfo(level: 0, filters: [], name: "Karosseri", selectedValues: [])),
            MultiLevelFilterComponent(filterInfo: DemoMultilevelFilterInfo(level: 0, filters: [], name: "Drivstoff", selectedValues: ["Elektrisitet"])),
            MultiLevelFilterComponent(filterInfo: DemoMultilevelFilterInfo(level: 0, filters: [], name: "Farge", selectedValues: ["Farge"])),
            MultiLevelFilterComponent(filterInfo: DemoMultilevelFilterInfo(level: 0, filters: [], name: "Hestekrefter", selectedValues: [])),
            MultiLevelFilterComponent(filterInfo: DemoMultilevelFilterInfo(level: 0, filters: [], name: "Antall seter", selectedValues: [])),
            MultiLevelFilterComponent(filterInfo: DemoMultilevelFilterInfo(level: 0, filters: [], name: "Hjuldrift", selectedValues: [])),
            MultiLevelFilterComponent(filterInfo: DemoMultilevelFilterInfo(level: 0, filters: [], name: "Girkasse", selectedValues: ["Automatisk"])),
            MultiLevelFilterComponent(filterInfo: DemoMultilevelFilterInfo(level: 0, filters: [], name: "Hjulsett", selectedValues: [])),
            MultiLevelFilterComponent(filterInfo: DemoMultilevelFilterInfo(level: 0, filters: [], name: "Garanti og forsikring", selectedValues: [])),
            MultiLevelFilterComponent(filterInfo: DemoMultilevelFilterInfo(level: 0, filters: [], name: "Bilens tilstand", selectedValues: [])),
            MultiLevelFilterComponent(filterInfo: DemoMultilevelFilterInfo(level: 0, filters: [], name: "Avgiftsklasse", selectedValues: [])),
        ]
    }

    static var preferenceFilters: [DemoPreferenceInfo] {
        return [
            DemoPreferenceInfo(name: "Type søk", values: [DemoPreferenceValue(name: "Til salgs"), DemoPreferenceValue(name: "Gis bort"), DemoPreferenceValue(name: "Ønskes kjøpt")]),
            DemoPreferenceInfo(name: "Tilstand", values: [DemoPreferenceValue(name: "Alle"), DemoPreferenceValue(name: "Brukt"), DemoPreferenceValue(name: "Nytt")]),
            DemoPreferenceInfo(name: "Selger", values: [DemoPreferenceValue(name: "Alle"), DemoPreferenceValue(name: "Forhandler"), DemoPreferenceValue(name: "Privat")]),
            DemoPreferenceInfo(name: "Publisert", values: [DemoPreferenceValue(name: "Nye i dag")]),
        ]
    }
}

private extension Array {
    /// Returns nil if index < count
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : .none
    }
}
