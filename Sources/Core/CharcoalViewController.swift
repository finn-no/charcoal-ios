//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol CharcoalViewControllerDelegate: class {
    func charcoalViewController(_ viewController: CharcoalViewController, didSelect vertical: Vertical)
    func charcoalViewControllerDidChangeSelection(_ viewController: CharcoalViewController)
}

public class CharcoalViewController: UINavigationController {

    // MARK: - Public properties

    public var filter: FilterContainer {
        didSet {
            rootFilterViewController.set(filter: filter.rootFilter, verticals: filter.verticals)
            isLoading = false
        }
    }

    public var isLoading: Bool = false {
        didSet {
            updateLoading()
        }
    }

    public var config: FilterConfiguration
    public weak var filterDelegate: CharcoalViewControllerDelegate?

    public var mapFilterViewManager: MapFilterViewManager?
    public var searchLocationDataSource: SearchLocationDataSource?

    // MARK: - Private properties

    private let selectionStore: FilterSelectionStore
    private var rootFilterViewController: RootFilterViewController

    private lazy var loadingViewController = LoadingViewController(backgroundColor: .milk, presentationDelay: 0)

    // MARK: - Init

    public init(filter: FilterContainer, config: FilterConfiguration, queryItems: Set<URLQueryItem> = []) {
        self.filter = filter
        self.config = config
        selectionStore = FilterSelectionStore(queryItems: queryItems)
        rootFilterViewController = RootFilterViewController(
            filter: filter.rootFilter,
            config: config,
            selectionStore: selectionStore
        )
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

// MARK: - RootFilterViewControllerDelegate

extension CharcoalViewController: RootFilterViewControllerDelegate {
    func rootFilterViewController(_ viewController: RootFilterViewController, didSelectVerticalAt index: Int) {
        guard let vertical = filter.verticals?[safe: index] else { return }
        filterDelegate?.charcoalViewController(self, didSelect: vertical)
    }
}

// MARK: - FilterViewControllerDelegate

extension CharcoalViewController: FilterViewControllerDelegate {
    func filterViewControllerDidSelectApply(_ viewController: FilterViewController) {
        filterDelegate?.charcoalViewControllerDidChangeSelection(self)
        popToRootViewController(animated: true)
    }

    func filterViewController(_ viewController: FilterViewController, didSelectFilter filter: Filter) {
        let nextViewController: FilterViewController

        switch filter.kind {
        case let .range(lowValueFilter, highValueFilter):
            guard let viewModel = config.rangeViewModel(forKey: filter.key) else { return }
            nextViewController = RangeFilterViewController(
                title: filter.title,
                lowValueFilter: lowValueFilter,
                highValueFilter: highValueFilter,
                viewModel: viewModel,
                selectionStore: selectionStore
            )
        case .stepper:
            guard let viewModel = config.rangeViewModel(forKey: filter.key) else { return }
            nextViewController = StepperFilterViewController(
                filter: filter,
                selectionStore: selectionStore,
                viewModel: viewModel
            )
        case let .map(latitudeFilter, longitudeFilter, radiusFilter, locationNameFilter):
            guard let mapFilterViewManager = mapFilterViewManager else { return }
            let mapViewController = MapFilterViewController(
                title: filter.title,
                latitudeFilter: latitudeFilter,
                longitudeFilter: longitudeFilter,
                radiusFilter: radiusFilter,
                locationNameFilter: locationNameFilter,
                selectionStore: selectionStore,
                mapFilterViewManager: mapFilterViewManager
            )
            mapViewController.searchLocationDataSource = searchLocationDataSource
            nextViewController = mapViewController
        case .inline, .search:
            return
        case .regular:
            guard !filter.subfilters.isEmpty else { return }

            nextViewController = ListFilterViewController(filter: filter, selectionStore: selectionStore)
            let showBottomButton = viewController === rootFilterViewController ? false : viewController.isShowingBottomButton
            nextViewController.showBottomButton(showBottomButton, animated: false)
        }

        nextViewController.delegate = self

        pushViewController(nextViewController, animated: true)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension CharcoalViewController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController is RangeFilterViewController {
            interactivePopGestureRecognizer?.isEnabled = false
        } else {
            interactivePopGestureRecognizer?.isEnabled = true
        }
    }
}
