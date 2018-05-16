//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class RootFilterNavigator: NSObject, Navigator {
    public enum Destination {
        case root
        case preferenceFilterInPopover(preferenceInfo: PreferenceInfo, sourceView: UIView, popoverWillDismiss: (() -> Void)?)
        case mulitLevelFilter(filterInfo: MultiLevelFilterInfo, delegate: MultiLevelFilterListViewControllerDelegate)
    }

    public typealias Factory = ViewControllerFactory

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
        case let .preferenceFilterInPopover(preferenceInfo, sourceView, popoverWillDismiss):
            presentPreference(with: preferenceInfo, and: sourceView, popoverWillDismiss: popoverWillDismiss)
        case let .mulitLevelFilter(filterInfo, delegate):
            if filterInfo.filters.isEmpty {
                return
            }

            guard let multiLevelFilterListViewController = factory.makeMultiLevelFilterListViewController(from: filterInfo) else {
                return
            }

            multiLevelFilterListViewController.delegate = delegate

            navigationController.pushViewController(multiLevelFilterListViewController, animated: true)
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

    func presentPreference(with preferenceInfo: PreferenceInfo, and sourceView: UIView, popoverWillDismiss: (() -> Void)?) {
        guard let preferencelistViewController = factory.makeListViewControllerForPreference(with: preferenceInfo), let filterRootViewController = filterRootViewController else {
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
