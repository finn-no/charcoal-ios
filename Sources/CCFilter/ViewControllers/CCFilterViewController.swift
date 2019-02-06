//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol CCFilterViewControllerDelegate: class {
    func filterViewControllerFilterSelectionChanged(_ filterViewController: CCFilterViewController)
    func filterViewControllerDidPressShowResults(_ filterViewController: CCFilterViewController)
}

public protocol MapFilterDataSource: class {
    func mapFilterViewManager(for mapFilterViewController: CCMapFilterViewController) -> MapFilterViewManager
    func searchLocationDataSource(for mapFilterViewController: CCMapFilterViewController) -> SearchLocationDataSource
}

public class CCFilterViewController: UINavigationController {

    // MARK: - Public properties

    public var filter: CCFilter
    public var config: CCFilterConfiguration

    public weak var filterDelegate: CCFilterViewControllerDelegate?
    public weak var mapFilterDataSource: MapFilterDataSource?

    // MARK: - Private properties

    private var rootFilterViewController: CCRootFilterViewController

    public init(filter: CCFilter, config: CCFilterConfiguration) {
        self.filter = filter
        self.config = config
        rootFilterViewController = CCRootFilterViewController(filterNode: filter.root)
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
        print(filter.urlEncoded)
        popToRootViewController(animated: true)
    }

    func viewController(_ viewController: CCViewController, didSelect filterNode: CCFilterNode) {
        guard !filterNode.children.isEmpty else { return }
        guard let nextController = config.viewController(for: filterNode) else { return }
        nextController.delegate = viewController

        if let mapController = nextController as? CCMapFilterViewController {
            mapController.mapFilterViewManager = mapFilterDataSource?.mapFilterViewManager(for: mapController)
            mapController.searchLocationDataSource = mapFilterDataSource?.searchLocationDataSource(for: mapController)
        }

        let showBottomButton = viewController === rootFilterViewController ? false : viewController.isShowingBottomButton
        nextController.showBottomButton(showBottomButton, animated: false)

        pushViewController(nextController, animated: true)
    }
}
