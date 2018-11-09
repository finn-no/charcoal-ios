//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit
import UIKit

enum Sections: String {
    case dna
    case components
    case fullscreen

    static var all: [Sections] {
        return [
            .components,
            .fullscreen,
            .dna,
        ]
    }

    var numberOfItems: Int {
        switch self {
        case .dna:
            return DnaViews.all.count
        case .components:
            return ComponentViews.all.count
        case .fullscreen:
            return FullscreenViews.all.count
        }
    }

    static func formattedName(for section: Int) -> String {
        let section = Sections.all[section]
        let rawClassName = section.rawValue
        return rawClassName.capitalizingFirstLetter
    }

    static func formattedName(for indexPath: IndexPath) -> String {
        let section = Sections.all[indexPath.section]
        var rawClassName: String
        switch section {
        case .dna:
            rawClassName = DnaViews.all[indexPath.row].rawValue
        case .components:
            rawClassName = ComponentViews.all[indexPath.row].rawValue
        case .fullscreen:
            rawClassName = FullscreenViews.all[indexPath.row].rawValue
        }

        return rawClassName.replacingOccurrences(of: "DemoView", with: "").capitalizingFirstLetter
    }

    static func viewController(for indexPath: IndexPath) -> UIViewController? {
        guard let section = Sections.all[safe: indexPath.section] else {
            return nil
        }
        let selectedViewController: UIViewController?
        switch section {
        case .dna:
            let selectedView = DnaViews.all[safe: indexPath.row]
            selectedViewController = selectedView?.viewController
        case .components:
            let selectedView = ComponentViews.all[safe: indexPath.row]
            selectedViewController = selectedView?.viewController
        case .fullscreen:
            let selectedView = FullscreenViews.all[safe: indexPath.row]
            selectedViewController = selectedView?.viewController
        }
        return selectedViewController
    }

    static func transitionStyle(for indexPath: IndexPath) -> TransitionStyle {
        let section = Sections.all[indexPath.section]
        switch section {
        case .components:
            let selectedView = ComponentViews.all[indexPath.row]
            switch selectedView {
            case .bottomSheet:
                return .bottomSheet
            case .rootFilters:
                return .none
            case .preferenceFilter:
                return .none
            case .list:
                return .none
            case .compactListFilter:
                return .bottomSheet
            case .rangeFilter:
                return .bottomSheet
            case .stepperFilter:
                return .bottomSheet
            case .searchQuery:
                return .none
            }
        case .fullscreen:
            let selectedView = FullscreenViews.all[indexPath.row]
            switch selectedView {
            case .torget, .bil, .eiendom:
                return .bottomSheet
            }
        default:
            return .none
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

public enum DnaViews: String {
    case color
    case font
    case assets

    static var all: [DnaViews] {
        return [
            .color,
            .font,
            .assets,
        ]
    }

    public var viewController: UIViewController {
        switch self {
        case .color:
            return ViewController<ColorDemoView>()
        case .font:
            return ViewController<FontDemoView>()
        case .assets:
            return ViewController<AssetsDemoView>()
        }
    }
}

enum ComponentViews: String {
    case bottomSheet
    case rootFilters
    case preferenceFilter
    case list
    case compactListFilter
    case rangeFilter
    case stepperFilter
    case searchQuery

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
            let factory = FilterDependencyContainer(dataSource: demoFilter, selectionDataSource: demoFilter.selectionDataSource, searchQuerySuggestionsDataSource: DemoSearchQuerySuggestionsDataSource(), filterDelegate: nil)
            let rootFilterNavigator = factory.makeRootFilterNavigator(navigationController: navigationController)

            rootFilterNavigator.start()

            return navigationController

        case .preferenceFilter:
            let popoverDemoViewController = PopoverDemoViewController()
            return popoverDemoViewController

        case .list:
            let viewController = ListViewController(title: "Kategori", items: ListViewControllerDemo.listItems)
            return viewController
        case .compactListFilter:
            return ViewController<CompactListFilterViewDemoView>()

        case .rangeFilter:
            return ViewController<RangeFilterDemoView>()
        case .stepperFilter:
            return ViewController<StepperFilterDemoView>()

        case .searchQuery:
            let searchQueryViewController = SearchQueryViewController(filterInfo: DemoSearchQueryFilterInfo(value: nil, placeholderText: "Søk etter ord", title: "Filtrer søket"), selectionDataSource: DemoEmptyFilterSelectionDataSource())!
            let navigationController = UINavigationController(rootViewController: searchQueryViewController)
            return navigationController
        }
    }

    static var all: [ComponentViews] {
        return [
            .bottomSheet,
            .rootFilters,
            .preferenceFilter,
            .list,
            .compactListFilter,
            .rangeFilter,
            .stepperFilter,
            .searchQuery,
        ]
    }
}

enum FullscreenViews: String {
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
        let factory = FilterDependencyContainer(dataSource: demoFilter, selectionDataSource: demoFilter.selectionDataSource, searchQuerySuggestionsDataSource: DemoSearchQuerySuggestionsDataSource(), filterDelegate: nil)
        let rootFilterNavigator = factory.makeRootFilterNavigator(navigationController: navigationController)

        rootFilterNavigator.start()

        return navigationController
    }

    static var all: [FullscreenViews] {
        return [
            .torget, .bil, .eiendom,
        ]
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
    var value: String?
    var placeholderText: String
    var title: String
}

class DemoEmptyFilterSelectionDataSource: FilterSelectionDataSource {
    func clearValueAndValueForChildren(for filterInfo: MultiLevelListSelectionFilterInfoType) {
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
}
