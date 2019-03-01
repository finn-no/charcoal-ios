//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol CharcoalViewControllerDelegate: class {
    func charcoalViewController(_ viewController: CharcoalViewController, didSelect vertical: Vertical)
    func charcoalViewController(_ viewController: CharcoalViewController, didChangeSelection selection: [URLQueryItem])
    func charcoalViewController(_ viewController: CharcoalViewController, didSelectExternalFilterWithKey key: String, value: String?)
}

public class CharcoalViewController: UINavigationController {

    // MARK: - Public properties

    public weak var filterDelegate: CharcoalViewControllerDelegate?

    // MARK: -

    public var freeTextFilterDelegate: FreeTextFilterDelegate? {
        get { return rootFilterViewController?.freeTextFilterDelegate }
        set { rootFilterViewController?.freeTextFilterDelegate = newValue }
    }

    public var freeTextFilterDataSource: FreeTextFilterDataSource? {
        get { return rootFilterViewController?.freeTextFilterDataSource }
        set { rootFilterViewController?.freeTextFilterDataSource = newValue }
    }

    // MARK: -

    public var mapFilterViewManager: MapFilterViewManager?
    public var searchLocationDataSource: SearchLocationDataSource?

    // MARK: -

    public var isLoading: Bool = false {
        didSet { updateLoading() }
    }

    // MARK: - Private properties

    private var filter: FilterContainer?
    private var config: FilterConfiguration?

    private var selectionHasChanged = false
    private var selectionStore = FilterSelectionStore()

    private var rootFilterViewController: RootFilterViewController?
    private lazy var loadingViewController = LoadingViewController(backgroundColor: .milk, presentationDelay: 0)

    // MARK: - Lifecycle

    public init() {
        super.init(nibName: nil, bundle: nil)
        selectionStore.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

    // MARK: - Public

    public func configure(with filter: FilterContainer, config: FilterConfiguration, queryItems: Set<URLQueryItem>? = nil) {
        self.filter = filter
        self.config = config

        if let queryItems = queryItems {
            selectionStore = FilterSelectionStore(queryItems: queryItems)
            selectionStore.delegate = self
        }

        if let rootFilterViewController = rootFilterViewController {
            rootFilterViewController.set(filter: filter.rootFilter, verticals: filter.verticals)
        } else {
            rootFilterViewController = RootFilterViewController(
                filter: filter.rootFilter,
                config: config,
                selectionStore: selectionStore
            )
            rootFilterViewController?.verticals = filter.verticals
            rootFilterViewController?.rootDelegate = self
            setViewControllers([rootFilterViewController!], animated: false)
        }
    }
}

// MARK: - RootFilterViewControllerDelegate

extension CharcoalViewController: RootFilterViewControllerDelegate {
    func rootFilterViewController(_ viewController: RootFilterViewController, didSelectVerticalAt index: Int) {
        guard let vertical = filter?.verticals?[safe: index] else { return }
        filterDelegate?.charcoalViewController(self, didSelect: vertical)
    }
}

// MARK: - FilterViewControllerDelegate

extension CharcoalViewController: FilterViewControllerDelegate {
    func filterViewControllerDidPressButtomButton(_ viewController: FilterViewController) {
        popToRootViewController(animated: true)
    }

    func filterViewController(_ viewController: FilterViewController, didSelectFilter filter: Filter) {
        switch filter.kind {
        case let .range(lowValueFilter, highValueFilter):
            guard let viewModel = config?.rangeViewModel(forKey: filter.key) else { break }
            let rangeViewController = RangeFilterViewController(
                title: filter.title,
                lowValueFilter: lowValueFilter,
                highValueFilter: highValueFilter,
                viewModel: viewModel,
                selectionStore: selectionStore
            )
            pushViewController(rangeViewController)
        case .stepper:
            guard let viewModel = config?.rangeViewModel(forKey: filter.key) else { break }
            let stepperViewController = StepperFilterViewController(
                filter: filter,
                selectionStore: selectionStore,
                viewModel: viewModel
            )
            pushViewController(stepperViewController)
        case let .map(latitudeFilter, longitudeFilter, radiusFilter, locationNameFilter):
            guard let mapFilterViewManager = mapFilterViewManager else { break }

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

            pushViewController(mapViewController)
        case .inline, .search:
            break
        case .external:
            filterDelegate?.charcoalViewController(self, didSelectExternalFilterWithKey: filter.key, value: filter.value)
        case .list:
            guard !filter.subfilters.isEmpty else { break }

            let listViewController = ListFilterViewController(filter: filter, selectionStore: selectionStore)
            let showBottomButton = viewController === rootFilterViewController ? false : viewController.isShowingBottomButton

            listViewController.showBottomButton(showBottomButton, animated: false)
            pushViewController(listViewController)
        }
    }

    private func pushViewController(_ viewController: FilterViewController) {
        viewController.delegate = self
        pushViewController(viewController, animated: true)
    }
}

// MARK: - FilterSelectionStoreDelegate

extension CharcoalViewController: FilterSelectionStoreDelegate {
    func filterSelectionStoreDidChange(_ selectionStore: FilterSelectionStore) {
        if topViewController === rootFilterViewController {
            // Changes in inline filters or removes selected filters
            guard let filter = filter else { return }
            filterDelegate?.charcoalViewController(self, didChangeSelection: selectionStore.queryItems(for: filter.rootFilter))
            selectionHasChanged = false
        } else {
            selectionHasChanged = true
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension CharcoalViewController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard viewController === rootFilterViewController else { return }
        // Will return to root filters
        if selectionHasChanged, let filter = filter {
            filterDelegate?.charcoalViewController(self, didChangeSelection: selectionStore.queryItems(for: filter.rootFilter))
            selectionHasChanged = false
        }
    }

    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController is RangeFilterViewController {
            interactivePopGestureRecognizer?.isEnabled = false
        } else {
            interactivePopGestureRecognizer?.isEnabled = true
        }
    }
}
