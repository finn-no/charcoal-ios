//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol CCFilterViewControllerDelegate: class {
    func filterViewControllerFilterSelectionChanged(_ filterViewController: CCFilterViewController)
    func filterViewControllerDidPressShowResults(_ filterViewController: CCFilterViewController)
    func filterViewController(_ filterViewController: CCFilterViewController, didSelectVerticalAt index: Int)
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

    public var config: CCFilterConfiguration
    public weak var filterDelegate: CCFilterViewControllerDelegate?

    public var mapFilterViewManager: MapFilterViewManager?
    public var searchLocationDataSource: SearchLocationDataSource?

    // MARK: - Private properties

    private let selectionStore: FilterSelectionStore
    private var rootFilterViewController: CCRootFilterViewController

    private lazy var loadingViewController = LoadingViewController(backgroundColor: .milk, presentationDelay: 0)

    public init(filter: CCFilter, config: CCFilterConfiguration) {
        self.filter = filter
        self.config = config
        selectionStore = FilterSelectionStore()
        rootFilterViewController = CCRootFilterViewController(filterNode: filter.root, selectionStore: selectionStore)
        rootFilterViewController.verticals = filter.verticals
        super.init(nibName: nil, bundle: nil)
        rootFilterViewController.rootDelegate = self
        setViewControllers([rootFilterViewController], animated: false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CCFilterViewController: CCRootFilterViewControllerDelegate {
    func rootFilterViewController(_ viewController: CCRootFilterViewController, didSelectVerticalAt index: Int) {
        filterDelegate?.filterViewController(self, didSelectVerticalAt: index)
    }

    func viewControllerDidPressBottomButton(_ viewController: CCViewController) {
        filterDelegate?.filterViewControllerFilterSelectionChanged(self)
        popToRootViewController(animated: true)
    }

    func viewController(_ viewController: CCViewController, didSelect filterNode: CCFilterNode) {
        guard !filterNode.isLeafNode else { return }
        let nextViewController: CCViewController

        switch filterNode {
        case let rangeNode as CCRangeFilterNode:
            guard let viewModel = config.viewModel(for: rangeNode) else { return }
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
            let mapFilterViewController = CCMapFilterViewController(mapFilterNode: mapNode,
                                                                    selectionStore: selectionStore,
                                                                    mapFilterViewManager: mapFilterViewManager,
                                                                    searchLocationDataSource: searchLocationDataSource)
            nextViewController = mapFilterViewController

        default:
            nextViewController = CCListFilterViewController(filterNode: filterNode, selectionStore: selectionStore)
            let showBottomButton = viewController === rootFilterViewController ? false : viewController.isShowingBottomButton
            nextViewController.showBottomButton(showBottomButton, animated: false)
        }

        nextViewController.delegate = viewController
        pushViewController(nextViewController, animated: true)
    }
}

private extension CCFilterViewController {
    func updateLoading() {
        if isLoading {
            add(loadingViewController)
            loadingViewController.viewWillAppear(false)
        } else {
            loadingViewController.remove()
        }
    }
}
