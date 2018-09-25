//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class RootFilterNavigator: NSObject, Navigator {
    public enum Destination {
        case root
        case selectionListFilter(filterInfo: ListSelectionFilterInfoType, selectionValue: FilterSelectionValue?, delegate: FilterViewControllerDelegate)
        case multiLevelSelectionListFilter(filterInfo: MultiLevelListSelectionFilterInfoType, selectionValue: FilterSelectionValue?, delegate: FilterViewControllerDelegate)
        case preferenceFilterInPopover(preferenceInfo: PreferenceInfoType, sourceView: UIView, selectionValue: FilterSelectionValue?, delegate: FilterViewControllerDelegate, popoverWillDismiss: (() -> Void)?)
        case rangeFilter(filterInfo: RangeFilterInfoType, selectionValue: FilterSelectionValue?, delegate: FilterViewControllerDelegate)
        case searchQueryFilter(filterInfo: SearchQueryFilterInfoType, delegate: FilterViewControllerDelegate)
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
        case let .multiLevelSelectionListFilter(filterInfo, selectionValue, delegate):
            let navigator = factory.makeFilterNavigator(navigationController: navigationController)
            guard let multiLevelListViewController = factory.makeMultiLevelListSelectionFilterViewController(from: filterInfo, navigator: navigator, delegate: delegate) else {
                return
            }
            if let selectionValue = selectionValue {
                multiLevelListViewController.setSelectionValue(selectionValue)
            }
            navigationController.pushViewController(multiLevelListViewController, animated: true)
        case let .preferenceFilterInPopover(preferenceInfo, sourceView, selectionValue, delegate, popoverWillDismiss):
            presentPreference(with: preferenceInfo, and: sourceView, selectionValue: selectionValue, delegate: delegate, popoverWillDismiss: popoverWillDismiss)
        case let .rangeFilter(filterInfo, selectionValue, delegate):
            let navigator = factory.makeFilterNavigator(navigationController: navigationController)
            guard let rangeFilterViewController = factory.makeRangeFilterViewController(with: filterInfo, navigator: navigator, delegate: delegate) else {
                return
            }
            if let selectionValue = selectionValue {
                rangeFilterViewController.setSelectionValue(selectionValue)
            }
            navigationController.pushViewController(rangeFilterViewController, animated: true)
        case let .selectionListFilter(filterInfo, selectionValue, delegate):
            let navigator = factory.makeFilterNavigator(navigationController: navigationController)
            guard let listSelectionViewController = factory.makeListSelectionFilterViewController(from: filterInfo, navigator: navigator, delegate: delegate) else {
                return
            }
            if let selectionValue = selectionValue {
                listSelectionViewController.setSelectionValue(selectionValue)
            }
            navigationController.pushViewController(listSelectionViewController, animated: true)
        case let .searchQueryFilter(filterInfo, delegate):
            let navigator = factory.makeFilterNavigator(navigationController: navigationController)
            guard let searchQueryViewController = factory.makeSearchQueryFilterViewController(from: filterInfo, navigator: navigator, delegate: delegate) else {
                return
            }

            if let bottomSheetPresentationController = navigationController.presentationController as? BottomSheetPresentationController, bottomSheetPresentationController.currentContentSizeMode != .expanded {
                navigationController.pushViewController(searchQueryViewController, animated: false)
                bottomSheetPresentationController.transition(to: .expanded)
            } else {
                navigationController.pushViewController(searchQueryViewController, animated: true)
            }
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

    func presentPreference(with preferenceInfo: PreferenceInfoType, and sourceView: UIView, selectionValue: FilterSelectionValue?, delegate: FilterViewControllerDelegate, popoverWillDismiss: (() -> Void)?) {
        let navigator = factory.makeFilterNavigator(navigationController: navigationController)
        guard let preferencelistViewController = factory.makePreferenceFilterListViewController(with: preferenceInfo, navigator: navigator, delegate: delegate), let filterRootViewController = filterRootViewController else {
            return
        }
        if let selectionValue = selectionValue {
            preferencelistViewController.setSelectionValue(selectionValue)
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
