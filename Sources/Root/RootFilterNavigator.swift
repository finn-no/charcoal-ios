//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class RootFilterNavigator: NSObject, Navigator {
    public enum Destination {
        case root
        case preferenceFilterInPopover(preferenceInfo: PreferenceInfo, sourceView: UIView, popoverWillDismiss: (() -> Void)?)
        case filter(filterInfo: FilterInfo)
        case mulitlevelFilter(mulitlevelFilterInfo: MultiLevelFilterInfo)
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
        case let .filter(filterInfo):
            guard let viewController = factory.makeViewControllerForFilter(with: filterInfo, navigator: self) else {
                return
            }

            navigationController.pushViewController(viewController, animated: true)
        case let .mulitlevelFilter(mulitlevelFilterInfo):
            guard let listViewController = factory.makeListViewControllerForMultiLevelFilterComponent(from: mulitlevelFilterInfo, navigator: self) else {
                return
            }

            navigationController.pushViewController(listViewController, animated: true)
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
