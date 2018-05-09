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
            case .horizontalScrollButtonGroupWithPopover:
                return .none
            }
        case .fullscreen:
            let selectedView = FullscreenViews.all[indexPath.row]
            switch selectedView {
            case .fullDemo:
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
    case horizontalScrollButtonGroupWithPopover

    var viewController: UIViewController {
        switch self {
        case .bottomSheet:
            let bottomSheetDemoViewController = BottomSheetDemoViewController()
            let navigationController = UINavigationController(rootViewController: bottomSheetDemoViewController)
            navigationController.transitioningDelegate = bottomSheetDemoViewController.bottomsheetTransitioningDelegate
            navigationController.modalPresentationStyle = .custom
            return navigationController

        case .rootFilters:
            let helper = FilterRootDemoViewControllerHelper.createHelperForDemo()
            let navigationController = FilterNavigationController()
            let factory = FilterFactory(dataSource: helper, delegate: helper)
            let filterNavigator = FilterNavigator(navigationController: navigationController, factory: factory)

            filterNavigator.start()

            return navigationController

        case .horizontalScrollButtonGroupWithPopover:
            let popoverDemoViewController = PopoverDemoViewController()
            return popoverDemoViewController
        }
    }

    static var all: [ComponentViews] {
        return [
            .bottomSheet,
            .rootFilters,
            .horizontalScrollButtonGroupWithPopover,
        ]
    }
}

enum FullscreenViews: String {
    case fullDemo

    var viewController: UIViewController {
        switch self {
        case .fullDemo:
            let helper = FilterRootDemoViewControllerHelper.createHelperForDemo()
            let navigationController = FilterNavigationController()
            let factory = FilterFactory(dataSource: helper, delegate: helper)
            let filterNavigator = FilterNavigator(navigationController: navigationController, factory: factory)

            filterNavigator.start()

            return navigationController
        }
    }

    static var all: [FullscreenViews] {
        return [
            .fullDemo,
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
