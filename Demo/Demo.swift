//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit
import UIKit

enum Sections: String {
    case components
    case fullscreen

    static var all: [Sections] {
        return [
            .components,
            .fullscreen,
        ]
    }

    var numberOfItems: Int {
        switch self {
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
        case .components:
            rawClassName = ComponentViews.all[indexPath.row].rawValue
        case .fullscreen:
            rawClassName = FullscreenViews.all[indexPath.row].rawValue
        }

        return rawClassName.replacingOccurrences(of: "DemoView", with: "").capitalizingFirstLetter
    }

    static func viewController(for indexPath: IndexPath) -> UIViewController {
        let section = Sections.all[indexPath.section]
        switch section {
        case .components:
            let selectedView = ComponentViews.all[indexPath.row]
            return selectedView.viewController
        case .fullscreen:
            let selectedView = FullscreenViews.all[indexPath.row]
            return selectedView.viewController
        }
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
            }
        case .fullscreen:
            let selectedView = FullscreenViews.all[indexPath.row]
            switch selectedView {
            case .fullDemoTorget, .fullDemoBil:
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

enum ComponentViews: String {
    case bottomSheet
    case rootFilters
    case preferenceFilter
    case list
    case compactListFilter
    case rangeFilter

    var viewController: UIViewController {
        switch self {
        case .bottomSheet:
            let bottomSheetDemoViewController = BottomSheetDemoViewController()
            let navigationController = UINavigationController(rootViewController: bottomSheetDemoViewController)
            navigationController.transitioningDelegate = bottomSheetDemoViewController.bottomsheetTransitioningDelegate
            navigationController.modalPresentationStyle = .custom
            return navigationController

        case .rootFilters:
            let filterData = DemoFilterDataSource.filterDataFromJSONFile(named: "car-norway")
            let dataSource = DemoFilterDataSource(filter: filterData)
            let navigationController = FilterNavigationController()
            let factory = FilterDependencyContainer(dataSource: dataSource)
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
        ]
    }
}

enum FullscreenViews: String {
    case fullDemoTorget
    case fullDemoBil

    var viewController: UIViewController {
        switch self {
        case .fullDemoTorget, .fullDemoBil:
            let filter: Filter
            switch self {
            case .fullDemoTorget:
                filter = DemoFilterDataSource.filterDataFromJSONFile(named: "bap-sale")
            case .fullDemoBil:
                filter = DemoFilterDataSource.filterDataFromJSONFile(named: "car-norway")
            }
            let dataSource = DemoFilterDataSource(filter: filter)
            let navigationController = FilterNavigationController()
            let factory = FilterDependencyContainer(dataSource: dataSource)
            let rootFilterNavigator = factory.makeRootFilterNavigator(navigationController: navigationController)

            rootFilterNavigator.start()

            return navigationController
        }
    }

    static var all: [FullscreenViews] {
        return [
            .fullDemoTorget, .fullDemoBil,
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
