//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol CCFilterViewControllerDelegate: class {
    func filterViewControllerFilterSelectionChanged(_ filterViewController: CCFilterViewController)
    func filterViewControllerDidPressShowResults(_ filterViewController: CCFilterViewController)
}

public protocol CCFilterViewControllerDataSource: class {
    func mapFilterViewManager(for filterViewController: CCFilterViewController) -> MapFilterViewManager
    func searchLocationDataSource(for filterViewController: CCFilterViewController) -> SearchLocationDataSource
}

public class CCFilterViewController: UINavigationController {

    // MARK: - Public properties

    public var filter: CCFilter
    public var config: CCFilterConfiguration

    public weak var filterDelegate: CCFilterViewControllerDelegate?
    public weak var mapFilterDataSource: CCFilterViewControllerDataSource?

    private let selectionStore: FilterSelectionStore

    // MARK: - Private properties

    private var rootFilterViewController: CCRootFilterViewController

    public init(filter: CCFilter, config: CCFilterConfiguration) {
        self.filter = filter
        self.config = config
        self.selectionStore = FilterSelectionStore()
        rootFilterViewController = CCRootFilterViewController(filterNode: filter.root, selectionStore: selectionStore)
        super.init(nibName: nil, bundle: nil)
        rootFilterViewController.delegate = self
        setViewControllers([rootFilterViewController], animated: false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            guard let viewModel = config.viewModel(for: rangeNode) else { return }
            nextViewController = CCRangeFilterViewController(filterNode: rangeNode, selectionStore: selectionStore, viewModel: viewModel)

        case let mapNode as CCMapFilterNode:
            let mapFilterViewController = CCMapFilterViewController(filterNode: mapNode, selectionStore: selectionStore)
            nextViewController = mapFilterViewController

        default:
            nextViewController = CCListFilterViewController(filterNode: filterNode, selectionStore: selectionStore)
        }

        let showBottomButton = viewController === rootFilterViewController ? false : viewController.isShowingBottomButton
        nextViewController.showBottomButton(showBottomButton, animated: false)
        nextViewController.delegate = viewController

        pushViewController(nextViewController, animated: true)
    }
}
