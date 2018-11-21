//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class RootFilterNavigator: NSObject, Navigator {
    public enum Destination {
        case root
        case selectionListFilter(filterInfo: ListSelectionFilterInfoType, delegate: FilterViewControllerDelegate)
        case multiLevelSelectionListFilter(filterInfo: MultiLevelListSelectionFilterInfoType, delegate: FilterViewControllerDelegate)
        case verticalSelectionInPopover(verticals: [Vertical], sourceView: UIView, delegate: VerticalListViewControllerDelegate, popoverWillDismiss: (() -> Void)?)
        case rangeFilter(filterInfo: RangeFilterInfoType, delegate: FilterViewControllerDelegate)
        case searchQueryFilter(filterInfo: SearchQueryFilterInfoType, delegate: FilterViewControllerDelegate)
        case stepperFilter(filterInfo: StepperFilterInfoType, delegate: FilterViewControllerDelegate)
    }

    public typealias Factory = ViewControllerFactory & FilterNavigtorFactory

    private let navigationController: FilterNavigationController
    private let factory: Factory
    private var filterRootStateController: FilterRootStateController?

    public init(navigationController: FilterNavigationController, factory: Factory) {
        self.navigationController = navigationController
        self.factory = factory
        super.init()
        navigationController.navigationBar.shadowImage = UIImage()
    }

    public func start() -> FilterRootStateController {
        let filterRootStateController = factory.makeFilterRootStateController(navigator: self)
        self.filterRootStateController = filterRootStateController
        navigationController.setViewControllers([filterRootStateController], animated: false)
        return filterRootStateController
    }

    public func navigate(to destination: RootFilterNavigator.Destination) {
        guard let filterDataSource = filterRootStateController?.currentFilterDataSource else {
            // We can't navigate to subfilters without having a filter data source
            return
        }
        switch destination {
        case .root:
            navigationController.popToRootViewController(animated: true)
        case let .multiLevelSelectionListFilter(filterInfo, delegate):
            let navigator = factory.makeFilterNavigator(navigationController: navigationController, dataSource: filterDataSource)
            guard let multiLevelListViewController = factory.makeMultiLevelListSelectionFilterViewController(from: filterInfo, navigator: navigator, delegate: delegate) else {
                return
            }
            navigationController.pushViewController(multiLevelListViewController, animated: true)
        case let .verticalSelectionInPopover(verticals, sourceView, delegate, popoverWillDismiss):
            presentVerticals(with: verticals, and: sourceView, delegate: delegate, popoverWillDismiss: popoverWillDismiss)
        case let .rangeFilter(filterInfo, delegate):
            let navigator = factory.makeFilterNavigator(navigationController: navigationController, dataSource: filterDataSource)
            guard let rangeFilterViewController = factory.makeRangeFilterViewController(with: filterInfo, navigator: navigator, delegate: delegate) else {
                return
            }
            navigationController.pushViewController(rangeFilterViewController, animated: true)
        case let .selectionListFilter(filterInfo, delegate):
            let navigator = factory.makeFilterNavigator(navigationController: navigationController, dataSource: filterDataSource)
            guard let listSelectionViewController = factory.makeListSelectionFilterViewController(from: filterInfo, navigator: navigator, delegate: delegate) else {
                return
            }
            navigationController.pushViewController(listSelectionViewController, animated: true)
        case let .searchQueryFilter(filterInfo, delegate):
            let navigator = factory.makeFilterNavigator(navigationController: navigationController, dataSource: filterDataSource)
            guard let searchQueryViewController = factory.makeSearchQueryFilterViewController(from: filterInfo, navigator: navigator, delegate: delegate) else {
                return
            }

            if let bottomSheetPresentationController = navigationController.presentationController as? BottomSheetPresentationController, bottomSheetPresentationController.currentContentSizeMode != .expanded {
                navigationController.pushViewController(searchQueryViewController, animated: false)
                bottomSheetPresentationController.transition(to: .expanded)
            } else {
                navigationController.pushViewController(searchQueryViewController, animated: true)
            }
        case let .stepperFilter(filterInfo, delegate):
            let navigator = factory.makeFilterNavigator(navigationController: navigationController, dataSource: filterDataSource)
            guard let stepperFilterViewController = factory.makeStepperFilterViewController(with: filterInfo, navigator: navigator, delegate: delegate) else { return }
            navigationController.pushViewController(stepperFilterViewController, animated: true)
        }
    }
}

private extension RootFilterNavigator {
    var filterRootViewController: FilterRootViewController? {
        let stateController = navigationController.viewControllers.first as? FilterRootStateController
        return stateController?.children.first as? FilterRootViewController
    }

    func presentVerticals(with verticals: [Vertical], and sourceView: UIView, delegate: VerticalListViewControllerDelegate, popoverWillDismiss: (() -> Void)?) {
        guard let preferencelistViewController = factory.makeVerticalListViewController(with: verticals, delegate: delegate), let filterRootViewController = filterRootViewController else {
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
