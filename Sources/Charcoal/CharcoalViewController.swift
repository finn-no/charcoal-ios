//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol CharcoalViewControllerDelegate: class {
    func charcoalViewController(_ viewController: CharcoalViewController, didSelect vertical: Vertical)
    func charcoalViewController(_ viewController: CharcoalViewController, didChangeSelection selection: [URLQueryItem])
    func charcoalViewController(_ viewController: CharcoalViewController, didSelectExternalFilterWithKey key: String, value: String?)
    func charcoalViewControllerDidPressShowResults(_ viewController: CharcoalViewController)
}

public class CharcoalViewController: UINavigationController {

    // MARK: - Public properties

    public var filter: FilterContainer? {
        didSet { configure(with: filter) }
    }

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

    private var selectionHasChanged = false
    private var selectionStore = FilterSelectionStore()

    private var rootFilterViewController: RootFilterViewController?
    private lazy var loadingViewController = LoadingViewController(backgroundColor: .milk, presentationDelay: 0)

    // MARK: - Init

    public init() {
        super.init(nibName: nil, bundle: nil)
        selectionStore.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }

    // MARK: - Public

    public func set(selection: Set<URLQueryItem>) {
        selectionStore.set(selection: selection)
        rootFilterViewController?.reloadFilters()
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

    private func configure(with filter: FilterContainer?) {
        guard let filter = filter else { return }

        if let rootFilterViewController = rootFilterViewController {
            rootFilterViewController.set(filter: filter.rootFilter, verticals: filter.verticals)
        } else {
            rootFilterViewController = RootFilterViewController(
                filter: filter.rootFilter,
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
    func rootFilterViewControllerDidChangeSelection(_ viewController: RootFilterViewController) {
        if let rootFilter = filter?.rootFilter {
            filterDelegate?.charcoalViewController(self, didChangeSelection: selectionStore.queryItems(for: rootFilter))
        }
    }

    func rootFilterViewController(_ viewController: RootFilterViewController, didSelectVerticalAt index: Int) {
        guard let vertical = filter?.verticals?[safe: index] else { return }
        filterDelegate?.charcoalViewController(self, didSelect: vertical)
    }
}

// MARK: - FilterViewControllerDelegate

extension CharcoalViewController: FilterViewControllerDelegate {
    func filterViewControllerDidPressButtomButton(_ viewController: FilterViewController) {
        if viewController === rootFilterViewController {
            filterDelegate?.charcoalViewControllerDidPressShowResults(self)
        } else {
            popToRootViewController(animated: true)
        }
    }

    func filterViewController(_ viewController: FilterViewController, didSelectFilter filter: Filter) {
        switch filter.kind {
        case let .range(lowValueFilter, highValueFilter, filterConfig):
            let rangeViewController = RangeFilterViewController(
                title: filter.title,
                lowValueFilter: lowValueFilter,
                highValueFilter: highValueFilter,
                filterConfig: filterConfig,
                selectionStore: selectionStore
            )
            pushViewController(rangeViewController)
        case let .stepper(filterConfig):
            let stepperViewController = StepperFilterViewController(
                filter: filter,
                selectionStore: selectionStore,
                filterConfig: filterConfig
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
        case .list:
            guard !filter.subfilters.isEmpty else { break }

            let listViewController = ListFilterViewController(filter: filter, selectionStore: selectionStore)
            let showBottomButton = viewController === rootFilterViewController ? false : viewController.isShowingBottomButton

            listViewController.showBottomButton(showBottomButton, animated: false)
            pushViewController(listViewController)
        case .external:
            filterDelegate?.charcoalViewController(self, didSelectExternalFilterWithKey: filter.key, value: filter.value)
        case .inline, .search:
            guard let rootFilter = self.filter?.rootFilter else { return }
            filterDelegate?.charcoalViewController(self, didChangeSelection: selectionStore.queryItems(for: rootFilter))
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
        if topViewController !== rootFilterViewController {
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