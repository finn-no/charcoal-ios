//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit

struct DemoFilterInfo: FilterInfo {
    let name: String
    let selectedValues: [String]
}

class DemoFilterRootViewControllerHelper: FilterRootViewControllerDataSource {
    var filters = [DemoFilterInfo]()
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
    var hasPreferences = true
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
            DemoFilterInfo(name: "Område", selectedValues: ["Oslo Øst"]),
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
            DemoFilterInfo(name: "Avgiftsklasse", selectedValues: [])
        ]
        dataSource.contextFilters = [
            DemoFilterInfo(name: "Kontekst filter", selectedValues: ["4", "2"]),
        ]
        return dataSource
    }    
}

extension DemoFilterRootViewControllerHelper: FilterRootViewControllerDelegate {

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

