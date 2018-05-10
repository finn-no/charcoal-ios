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

    var numberOfValues: Int {
        return values.count
    }

    func value(at index: Int) -> PreferenceValue? {
        return values[safe: index]
    }
}

struct DemoFilterInfo: FilterInfo {
    let name: String
    let selectedValues: [String]
}

struct DemoMultilevelFilterInfo: MultiLevelFilterInfo {
    var level: Int

    var filters: [MultiLevelFilterInfo]

    var name: String

    var selectedValues: [String]
}

class FilterRootDemoViewControllerHelper: FilterRootViewControllerDataSource {
    func multilevelFilter(atIndex index: Int, forFilterAtIndex filterIndex: Int) -> MultiLevelFilterInfo? {
        guard let multiLevelFilterInfo = filters[safe: filterIndex] as? MultiLevelFilterInfo else {
            return nil
        }

        return multiLevelFilterInfo.filters[safe: index]
    }

    private lazy var horizontalScrollButtonGroupViewDemoView: HorizontalScrollButtonGroupViewDemoView? = {
        return HorizontalScrollButtonGroupViewDemoView(frame: .zero)
    }()

    var filters = [FilterInfo]()
    var contextFilters = [DemoFilterInfo]()

    var numberOfFilters: Int {
        return filters.count
    }

    var numberOfContextFilters: Int {
        return contextFilters.count
    }

    func filter(at index: Int) -> FilterInfo? {
        return filters[safe: index]
    }

    func contextFilter(at index: Int) -> FilterInfo? {
        return contextFilters[safe: index]
    }

    var currentSearchQuery: String?
    var numberOfHits: Int? = 42
    var searchQueryPlaceholder: String {
        return "Ord i annonsen"
    }

    var doneButtonTitle: String {
        if let numberOfHits = numberOfHits {
            return "Vis \(numberOfHits) treff"
        } else {
            return "Vis treff"
        }
    }

    static func createHelperForDemo() -> Self {
        let dataSource = self.init()
        dataSource.currentSearchQuery = nil
        dataSource.filters = [
            DemoFilterInfo(name: "Merke", selectedValues: ["Toyota"]),
            DemoFilterInfo(name: "Årsmodell", selectedValues: ["2000 - 2017"]),
            DemoFilterInfo(name: "Kilometerstand", selectedValues: []),
            DemoFilterInfo(name: "Pris", selectedValues: []),
            //            DemoFilterInfo(name: "Område", selectedValues: ["Oslo Øst"]),
            DemoMultilevelFilterInfo(level: 0, filters: [
                DemoMultilevelFilterInfo(level: 1, filters: [
                    DemoMultilevelFilterInfo(level: 1, filters: [], name: "Alle", selectedValues: []),
                ], name: "Oslo", selectedValues: []),
                DemoMultilevelFilterInfo(level: 1, filters: [], name: "Østfold", selectedValues: []),
            ], name: "Område", selectedValues: ["Oslo Øst"]),
            DemoFilterInfo(name: "Karosseri", selectedValues: []),
            DemoFilterInfo(name: "Drivstoff", selectedValues: ["Elektrisitet]"]),
            DemoFilterInfo(name: "Farge", selectedValues: ["Farge"]),
            DemoFilterInfo(name: "Hestekrefter", selectedValues: []),
            DemoFilterInfo(name: "Antall seter", selectedValues: []),
            DemoFilterInfo(name: "Hjuldrift", selectedValues: []),
            DemoFilterInfo(name: "Girkasse", selectedValues: ["Automatisk"]),
            DemoFilterInfo(name: "Ekstrautstyr", selectedValues: []),
            DemoFilterInfo(name: "Hjulsett", selectedValues: []),
            DemoFilterInfo(name: "Garanti og forsikring", selectedValues: []),
            DemoFilterInfo(name: "Bilens tilstand", selectedValues: []),
            DemoFilterInfo(name: "Avgiftsklasse", selectedValues: []),
        ]
        dataSource.contextFilters = [
            DemoFilterInfo(name: "Kontekst filter", selectedValues: ["4", "2"]),
        ]
        return dataSource
    }
}

extension FilterRootDemoViewControllerHelper: FilterRootViewControllerPreferenceDataSource {
    var hasPreferences: Bool {
        return FilterRootDemoViewControllerHelper.preferenceFilters.count > 0
    }

    var preferencesDataSource: HorizontalScrollButtonGroupViewDataSource? {
        return horizontalScrollButtonGroupViewDemoView
    }

    func preference(at index: Int) -> PreferenceInfo? {
        return FilterRootDemoViewControllerHelper.preferenceFilters[safe: index]
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

extension FilterRootDemoViewControllerHelper: FilterRootViewControllerDelegate {
    func filterRootViewControllerDidSelectShowResults(_ filterRootViewController: FilterRootViewController) {
        filterRootViewController.navigationController?.presentingViewController?.dismiss(animated: true, completion: {
        })
    }

    func filterRootViewController(_ filterRootViewController: FilterRootViewController, didSelectFilterAt indexPath: IndexPath) {
    }

    func filterRootViewController(_ filterRootViewController: FilterRootViewController, didSelectContextFilterAt indexPath: IndexPath) {
    }
}

private extension Array {
    /// Returns nil if index < count
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : .none
    }
}
