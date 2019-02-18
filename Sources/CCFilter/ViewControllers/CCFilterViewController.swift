//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol CCFilterViewControllerDelegate: class {
    func filterViewControllerFilterSelectionChanged(_ filterViewController: CCFilterViewController)
    func filterViewControllerDidPressShowResults(_ filterViewController: CCFilterViewController)
    func filterViewController(_ filterViewController: CCFilterViewController, didSelect vertical: Vertical)
}

public class CCFilterViewController: UINavigationController {

    // MARK: - Public properties

    public var filter: CCFilter {
        didSet {
            rootFilterViewController.set(filterNode: filter.root, verticals: filter.verticals)
            isLoading = false
        }
    }

    public var isLoading: Bool = false {
        didSet {
            updateLoading()
        }
    }

    public var config: FilterConfiguration
    public weak var filterDelegate: CCFilterViewControllerDelegate?

    public var mapFilterViewManager: MapFilterViewManager?
    public var searchLocationDataSource: SearchLocationDataSource?

    // MARK: - Private properties

    private let selectionStore: FilterSelectionStore
    private var rootFilterViewController: CCRootFilterViewController

    private lazy var loadingViewController = LoadingViewController(backgroundColor: .milk, presentationDelay: 0)

    // MARK: - Init

    public init(filter: CCFilter, config: FilterConfiguration, queryItems: Set<URLQueryItem> = []) {
        self.filter = filter
        self.config = config
        selectionStore = FilterSelectionStore(queryItems: queryItems)
        rootFilterViewController = CCRootFilterViewController(filterNode: filter.root, selectionStore: selectionStore)
        rootFilterViewController.verticals = filter.verticals
        super.init(nibName: nil, bundle: nil)
        rootFilterViewController.rootDelegate = self
        setViewControllers([rootFilterViewController], animated: false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }

    // MARK: - Private

    private func updateLoading() {
        if isLoading {
            add(loadingViewController)
            loadingViewController.viewWillAppear(false)
        } else {
            loadingViewController.remove()
        }
    }
}

// MARK: - CCRootFilterViewControllerDelegate

extension CCFilterViewController: CCRootFilterViewControllerDelegate {
    func rootFilterViewController(_ viewController: CCRootFilterViewController, didSelectVerticalAt index: Int) {
        guard let vertical = filter.verticals?[safe: index] else { return }
        filterDelegate?.filterViewController(self, didSelect: vertical)
    }
}

extension CCFilterViewController: CCViewControllerDelegate {
    func viewControllerDidPressBottomButton(_ viewController: CCViewController) {
        filterDelegate?.filterViewControllerFilterSelectionChanged(self)
        popToRootViewController(animated: true)
    }

    func viewController(_ viewController: CCViewController, didSelect filterNode: CCFilterNode) {
        guard !filterNode.isLeafNode else { return }
        let nextViewController: CCViewController

        switch filterNode {
        case let rangeNode as CCRangeFilterNode:
            guard let viewModel = config.viewModel(forKey: rangeNode.name) else { return }
            switch viewModel.kind {
            case .slider:
                nextViewController = CCRangeFilterViewController(
                    rangeFilterNode: rangeNode,
                    viewModel: viewModel,
                    selectionStore: selectionStore
                )
            case .stepper:
                nextViewController = CCStepperFilterViewController(
                    filterNode: rangeNode,
                    selectionStore: selectionStore,
                    viewModel: viewModel
                )
            }
        case let mapNode as CCMapFilterNode:
            guard let mapFilterViewManager = mapFilterViewManager else { return }
            nextViewController = CCMapFilterViewController(mapFilterNode: mapNode,
                                                           selectionStore: selectionStore,
                                                           mapFilterViewManager: mapFilterViewManager,
                                                           searchLocationDataSource: searchLocationDataSource)

        default:
            nextViewController = CCListFilterViewController(filterNode: filterNode, selectionStore: selectionStore)
            let showBottomButton = viewController === rootFilterViewController ? false : viewController.isShowingBottomButton
            nextViewController.showBottomButton(showBottomButton, animated: false)
        }

        nextViewController.delegate = viewController
        pushViewController(nextViewController, animated: true)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension CCFilterViewController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController is CCRangeFilterViewController {
            interactivePopGestureRecognizer?.isEnabled = false
        } else {
            interactivePopGestureRecognizer?.isEnabled = true
        }
    }
}
