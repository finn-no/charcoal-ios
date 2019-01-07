//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import UIKit

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
            case .bottomSheet:
                return .bottomSheet
            case .rootFilters:
                return .none
            case .listSelection:
                return .none
            case .compactListFilter:
                return .bottomSheet
            case .rangeFilter:
                return .bottomSheet
            case .stepperFilter:
                return .bottomSheet
            case .inlineFilter:
                return .none
            case .mapFilter:
                return .none
            }
        case .fullscreen:
            let selectedView = FullscreenViews.allCases[indexPath.row]
            switch selectedView {
            case .torget, .bil, .eiendom:
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
    case bottomSheet
    case rootFilters
    case listSelection
    case compactListFilter
    case rangeFilter
    case stepperFilter
    case inlineFilter
    case mapFilter

    var viewController: UIViewController {
        switch self {
        case .bottomSheet:
            let bottomSheetDemoViewController = BottomSheetDemoViewController()
            let navigationController = UINavigationController(rootViewController: bottomSheetDemoViewController)
            navigationController.transitioningDelegate = bottomSheetDemoViewController.bottomsheetTransitioningDelegate
            navigationController.modalPresentationStyle = .custom
            return navigationController

        case .rootFilters:
            let filterData = DemoFilter.filterDataFromJSONFile(named: "car-norway")
            let demoFilter = DemoFilter(filter: filterData)
            let navigationController = FilterNavigationController()
            let factory = FilterDependencyContainer(selectionDataSource: demoFilter.selectionDataSource, searchQuerySuggestionsDataSource: DemoSearchQuerySuggestionsDataSource(), filterDelegate: nil, filterSelectionTitleProvider: FilterSelectionTitleProvider(), mapFilterViewManager: MapViewManager())
            let rootFilterNavigator = factory.makeRootFilterNavigator(navigationController: navigationController)

            let stateController = rootFilterNavigator.start()
            stateController.change(to: .loadFreshFilters(data: demoFilter))

            return navigationController

        case .listSelection:
            let viewController = ListSelectionFilterViewController(filterInfo: DemoListSelectionFilterInfo(), dataSource: DemoListDataSource(), selectionDataSource: DemoListFilterSelectionDataSource())!
            return viewController
        case .compactListFilter:
            return ViewController<CompactListFilterViewDemoView>()

        case .rangeFilter:
            return ViewController<RangeFilterDemoView>()
        case .stepperFilter:
            return ViewController<StepperFilterDemoView>()

        case .inlineFilter:
            let controller = InlineFilterDemoViewController()
            controller.selectionDataSource = DemoEmptyFilterSelectionDataSource()
            return controller

        case .mapFilter:
            let mapViewManager = MapViewManager()
            let mapFilterViewController = MapFilterViewController(filterInfo: DemoListSelectionFilterInfo(), dataSource: DemoListDataSource(), selectionDataSource: DemoListFilterSelectionDataSource())!
            mapFilterViewController.mapFilterViewManager = mapViewManager
            return mapFilterViewController
        }
    }
}

enum FullscreenViews: String, CaseIterable {
    case torget
    case bil
    case eiendom

    var viewController: UIViewController {
        let filter: FilterSetup

        switch self {
        case .torget:
            filter = DemoFilter.filterDataFromJSONFile(named: "bap-sale")
        case .bil:
            filter = DemoFilter.filterDataFromJSONFile(named: "car-norway")
        case .eiendom:
            filter = DemoFilter.filterDataFromJSONFile(named: "realestate-homes")
        }

        let demoFilter = DemoFilter(filter: filter)
        let navigationController = FilterNavigationController()
        let factory = FilterDependencyContainer(selectionDataSource: demoFilter.selectionDataSource, searchQuerySuggestionsDataSource: DemoSearchQuerySuggestionsDataSource(), filterDelegate: demoFilter, filterSelectionTitleProvider: FilterSelectionTitleProvider(), mapFilterViewManager: MapViewManager())
        let rootFilterNavigator = factory.makeRootFilterNavigator(navigationController: navigationController)

        let stateController = rootFilterNavigator.start()
        stateController.change(to: .loadFreshFilters(data: demoFilter))

        return navigationController
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

struct DemoSearchQueryFilterInfo: SearchQueryFilterInfoType {
    var placeholderText: String
    var title: String
}

class DemoEmptyFilterSelectionDataSource: FilterSelectionDataSource {
    func clearValueAndValueForChildren(for filterInfo: MultiLevelListSelectionFilterInfoType) {
    }

    func clearSelection(at selectionValueIndex: Int, in selectionInfo: FilterSelectionInfo) {
    }

    func stepperValue(for filterInfo: StepperFilterInfoType) -> Int? {
        return nil
    }

    func selectionState(_ filterInfo: MultiLevelListSelectionFilterInfoType) -> MultiLevelListItemSelectionState {
        return .none
    }

    func value(for filterInfo: FilterInfoType) -> [String]? {
        return nil
    }

    func valueAndSubLevelValues(for filterInfo: FilterInfoType) -> [FilterSelectionInfo] {
        return []
    }

    func setValue(_ filterSelectionValue: [String]?, for filterInfo: FilterInfoType) {
    }

    func addValue(_ value: String, for filterInfo: FilterInfoType) {
    }

    func clearAll(for filterInfo: FilterInfoType) {
    }

    func clearValue(_ value: String, for filterInfo: FilterInfoType) {
    }

    func rangeValue(for filterInfo: RangeFilterInfoType) -> RangeValue? {
        return nil
    }

    func setValue(_ range: RangeValue, for filterInfo: FilterInfoType) {
    }

    func setValue(latitude: Double, longitude: Double, radius: Int, locationName: String?, for filterInfo: FilterInfoType) {
    }

    func setValue(geoFilterValue: GeoFilterValue, for filterInfo: FilterInfoType) {
    }

    func geoValue(for filterInfo: FilterInfoType) -> GeoFilterValue? {
        return nil
    }
}

class DemoEmptyDataSource: FilterDataSource {
    var searchQuery: SearchQueryFilterInfoType?

    var verticals: [Vertical] = []

    var preferences: [PreferenceFilterInfoType] = []

    var filters: [FilterInfoType] = []

    var numberOfHits: Int = 0

    var filterTitle: String = "Demo"

    func numberOfHits(for filterValue: FilterValueType) -> Int {
        return 42
    }
}
