//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class RootFilterNavigator: NSObject, Navigator {
    public enum Destination {
        case root
        case mulitLevelFilter(filterInfo: MultiLevelSelectionFilterInfoType, delegate: FilterViewControllerDelegate)
        case preferenceFilterInPopover(preferenceInfo: PreferenceInfoType, sourceView: UIView, delegate: FilterViewControllerDelegate, popoverWillDismiss: (() -> Void)?)
        case rangeFilter(filterInfo: RangeFilterInfoType, delegate: FilterViewControllerDelegate)
    }

    public typealias Factory = ViewControllerFactory & FilterNavigtorFactory

    private let navigationController: FilterNavigationController
    private let factory: Factory

    public init(navigationController: FilterNavigationController, factory: Factory) {
        self.navigationController = navigationController
        self.factory = factory
        super.init()

        navigationController.onViewDidLoad = navigationControllerViewDidLoad
    }

    public func start() {
        let filterRootViewController = factory.makeFilterRootViewController(navigator: self)
        navigationController.setViewControllers([filterRootViewController], animated: false)
    }

    public func navigate(to destination: RootFilterNavigator.Destination) {
        switch destination {
        case .root:
            navigationController.popToRootViewController(animated: true)
        case let .mulitLevelFilter(filterInfo, delegate):
            if filterInfo.filters.isEmpty {
                return
            }

            let navigator = factory.makeFilterNavigator(navigationController: navigationController)
            navigator.navigate(to: .subLevel(filterInfo: filterInfo, delegate: delegate))
        case let .preferenceFilterInPopover(preferenceInfo, sourceView, delegate, popoverWillDismiss):
            presentPreference(with: preferenceInfo, and: sourceView, delegate: delegate, popoverWillDismiss: popoverWillDismiss)
        case let .rangeFilter(filterInfo, delegate):
            let navigator = factory.makeFilterNavigator(navigationController: navigationController)
            guard let rangeFilterViewController = factory.makeRangeFilterViewController(with: filterInfo, navigator: navigator, delegate: delegate) else {
                return
            }

            navigationController.pushViewController(rangeFilterViewController, animated: true)
        }
    }
}

private extension RootFilterNavigator {
    var filterRootViewController: FilterRootViewController? {
        return navigationController.viewControllers.first as? FilterRootViewController
    }

    func navigationControllerViewDidLoad(_ filterNavigationController: FilterNavigationController) {
        if let bottomSheetPresentationController = filterNavigationController.presentationController as? BottomSheetPresentationController {
            bottomSheetPresentationController.delegate = filterRootViewController
        }
    }

    func presentPreference(with preferenceInfo: PreferenceInfoType, and sourceView: UIView, delegate: FilterViewControllerDelegate, popoverWillDismiss: (() -> Void)?) {
        let navigator = factory.makeFilterNavigator(navigationController: navigationController)
        guard let preferencelistViewController = factory.makePreferenceFilterListViewController(with: preferenceInfo, navigator: navigator, delegate: delegate), let filterRootViewController = filterRootViewController else {
            return
        }

        let transitioningDelegate = CustomPopoverPresentationTransitioningDelegate()

        transitioningDelegate.willDismissPopoverHandler = { _ in
            popoverWillDismiss?()
        }

        transitioningDelegate.didDismissPopoverHandler = { _ in
            filterRootViewController.popoverPresentationTransitioningDelegate = nil
        }

        transitioningDelegate.sourceView = sourceView

        filterRootViewController.popoverPresentationTransitioningDelegate = transitioningDelegate

        preferencelistViewController.preferredContentSize = CGSize(width: filterRootViewController.view.frame.size.width, height: 144)
        preferencelistViewController.modalPresentationStyle = .custom
        preferencelistViewController.transitioningDelegate = transitioningDelegate

        filterRootViewController.present(preferencelistViewController, animated: true, completion: nil)
    }
}
