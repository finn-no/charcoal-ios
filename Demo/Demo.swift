//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

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
    case helloWorld

    var viewController: UIViewController {
        switch self {
        case .helloWorld:
            return ViewController(nibName: nil, bundle: nil)
        }
    }

    static var all: [ComponentViews] {
        return [
            .helloWorld,
        ]
    }
}

enum FullscreenViews: String {
    case bottomsheet

    var viewController: UIViewController {
        switch self {
        case .bottomsheet:
            return BottomsheetDemoViewController()
        }
    }

    static var all: [FullscreenViews] {
        return [
            .bottomsheet,
        ]
    }
}

extension String {
    var capitalizingFirstLetter: String {
        return prefix(1).uppercased() + dropFirst()
    }
}
