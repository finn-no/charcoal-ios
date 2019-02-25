//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal

enum Sections: String, CaseIterable {
    case components
    case fullscreen

    var numberOfItems: Int {
        switch self {
        case .components:
            return ComponentViews.allCases.count
        case .fullscreen:
            return FullscreenViews.allCases.count
        }
    }

    static func formattedName(for section: Int) -> String {
        let section = Sections.allCases[section]
        let rawClassName = section.rawValue
        return rawClassName.capitalizingFirstLetter
    }

    static func formattedName(for indexPath: IndexPath) -> String {
        let section = Sections.allCases[indexPath.section]
        var rawClassName: String?
        switch section {
        case .components:
            rawClassName = ComponentViews.allCases[safe: indexPath.row]?.rawValue
        case .fullscreen:
            rawClassName = FullscreenViews.allCases[safe: indexPath.row]?.rawValue
        }

        return rawClassName?.replacingOccurrences(of: "DemoView", with: "").capitalizingFirstLetter ?? "Unknown"
    }

    static func marketName(for indexPath: IndexPath) -> String? {
        guard let section = Sections.allCases[safe: indexPath.section] else {
            return nil
        }
        switch section {
        case .components:
            return nil
        case .fullscreen:
            return FullscreenViews.allCases[safe: indexPath.row]?.marketName
        }
    }

    static func viewController(for indexPath: IndexPath) -> UIViewController? {
        guard let section = Sections.allCases[safe: indexPath.section] else {
            return nil
        }
        let selectedViewController: UIViewController?
        switch section {
        case .components:
            let selectedView = ComponentViews.allCases[safe: indexPath.row]
            selectedViewController = selectedView?.viewController
        case .fullscreen:
            let selectedView = FullscreenViews.allCases[safe: indexPath.row]
            selectedViewController = selectedView?.viewController
        }
        return selectedViewController
    }

    static func transitionStyle(for indexPath: IndexPath) -> TransitionStyle {
        let section = Sections.allCases[indexPath.section]
        switch section {
        case .components:
            let selectedView = ComponentViews.allCases[indexPath.row]
            switch selectedView {
            case .listSelection:
                return .bottomSheet
            case .compactListFilter:
                return .bottomSheet
            case .rangeFilter:
                return .bottomSheet
            case .stepperFilter:
                return .bottomSheet
            case .inlineFilter:
                return .none
            case .mapFilter:
                return .bottomSheet
            }
        case .fullscreen:
            let selectedView = FullscreenViews.allCases[indexPath.row]
            switch selectedView {
            case .torget, .bil, .eiendom, .job, .mc, .boat, .b2b:
                return .bottomSheet
            }
        }
    }

    private static let lastSelectedRowKey = "lastSelectedRowKey"
    private static let lastSelectedSectionKey = "lastSelectedSectionKey"

    static var lastSelectedIndexPath: IndexPath? {
        get {
            guard let row = UserDefaults.standard.object(forKey: lastSelectedRowKey) as? Int else { return nil }
            guard let section = UserDefaults.standard.object(forKey: lastSelectedSectionKey) as? Int else { return nil }
            return IndexPath(row: row, section: section)
        }
        set {
            if let row = newValue?.row {
                UserDefaults.standard.set(row, forKey: lastSelectedRowKey)
            } else {
                UserDefaults.standard.removeObject(forKey: lastSelectedRowKey)
            }

            if let section = newValue?.section {
                UserDefaults.standard.set(section, forKey: lastSelectedSectionKey)
            } else {
                UserDefaults.standard.removeObject(forKey: lastSelectedSectionKey)
            }
            UserDefaults.standard.synchronize()
        }
    }
}

enum ComponentViews: String, CaseIterable {
    case listSelection
    case compactListFilter
    case rangeFilter
    case stepperFilter
    case inlineFilter
    case mapFilter

    var viewController: UIViewController {
        switch self {
        case .listSelection:
            let subfilters = [
                Filter.list(title: "Akershus", key: "", numberOfResults: 1238),
                Filter.list(title: "Buskerud", key: "", numberOfResults: 3421),
            ]

            let rootFilter = Filter.list(title: "Liste", key: "", subfilters: subfilters)

            return ListFilterViewController(
                filter: rootFilter,
                selectionStore: FilterSelectionStore()
            )
        case .compactListFilter:
            return ViewController<CompactListFilterViewDemoView>()
        case .rangeFilter:
            return ViewController<RangeFilterDemoView>()
        case .stepperFilter:
            return ViewController<StepperFilterDemoView>()
        case .inlineFilter:
            let controller = InlineFilterDemoViewController()
            return controller
        case .mapFilter:
            let mapFilter = Filter.map(
                title: "Område i kart",
                key: "map",
                latitudeKey: "lat",
                longitudeKey: "lon",
                radiusKey: "radius",
                locationKey: "geoLocationName"
            )

            let mapViewController = MapFilterViewController(
                title: mapFilter.title,
                latitudeFilter: mapFilter.subfilters[0],
                longitudeFilter: mapFilter.subfilters[1],
                radiusFilter: mapFilter.subfilters[2],
                locationNameFilter: mapFilter.subfilters[3],
                selectionStore: FilterSelectionStore(),
                mapFilterViewManager: MapViewManager()
            )

            mapViewController.searchLocationDataSource = DemoSearchLocationDataSource()

            return mapViewController
        }
    }
}

enum FullscreenViews: String, CaseIterable {
    case torget
    case bil
    case eiendom
    case mc
    case job
    case boat
    case b2b

    var viewController: UIViewController? {
        return nil
    }

    var marketName: String {
        switch self {
        case .torget: return "bap-sale"
        case .bil: return "car-norway"
        case .eiendom: return "realestate-homes"
        case .mc: return "mc"
        case .job: return "job-full-time"
        case .boat: return "boat-sale"
        case .b2b: return "truck"
        }
    }
}

enum TransitionStyle {
    case none
    case bottomSheet
}

extension String {
    var capitalizingFirstLetter: String {
        return prefix(1).uppercased() + dropFirst()
    }
}
