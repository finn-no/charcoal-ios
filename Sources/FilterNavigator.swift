//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class FilterNavigator: NSObject, Navigator {
    public enum Destination {
        case root
        case preferenceFilterInPopover(preferenceIndex: Int, sourceView: UIView, popoverWillDismiss: (() -> Void)?)
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

    func navigate(to destination: FilterNavigator.Destination) {
        switch destination {
        case .root:
            navigationController.popToRootViewController(animated: true)
        case let .preferenceFilterInPopover(preferenceIndex, sourceView, popoverWillDismiss):
            presentPreference(at: preferenceIndex, with: sourceView, popoverWillDismiss: popoverWillDismiss)
        }
    }
}

private extension FilterNavigator {
    var filterRootViewController: FilterRootViewController? {
        return navigationController.viewControllers.first as? FilterRootViewController
    }

    func navigationControllerViewDidLoad(_ filterNavigationController: FilterNavigationController) {
        if let bottomSheetPresentationController = filterNavigationController.presentationController as? BottomSheetPresentationController {
            bottomSheetPresentationController.delegate = filterRootViewController
        }
    }

    func presentPreference(at preferenceIndex: Int, with sourceView: UIView, popoverWillDismiss: (() -> Void)?) {
        guard let preferencelistViewController = factory.makeListViewControllerForPreference(at: preferenceIndex), let filterRootViewController = filterRootViewController else {
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
