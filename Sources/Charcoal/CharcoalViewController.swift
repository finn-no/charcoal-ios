//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol CharcoalViewControllerTextEditingDelegate: AnyObject {
    func charcoalViewControllerWillBeginTextEditing(_ viewController: CharcoalViewController)
    func charcoalViewControllerWillEndTextEditing(_ viewController: CharcoalViewController)
}

public protocol CharcoalViewControllerSelectionDelegate: AnyObject {
    func charcoalViewController(_ viewController: CharcoalViewController, didSelect vertical: Vertical)
    func charcoalViewController(_ viewController: CharcoalViewController, didSelectExternalFilterWithKey key: String, value: String?)
    func charcoalViewControllerDidPressShowResults(_ viewController: CharcoalViewController)
    func charcoalViewController(_ viewController: CharcoalViewController,
                                didChangeSelection selection: [URLQueryItem],
                                origin: SelectionChangeOrigin)
}

public class CharcoalViewController: UINavigationController {

    // MARK: - Public properties

    public var filterContainer: FilterContainer? {
        didSet { configure(with: filterContainer) }
    }

    public weak var textEditingDelegate: CharcoalViewControllerTextEditingDelegate?
    public weak var selectionDelegate: CharcoalViewControllerSelectionDelegate?
    public weak var mapDataSource: MapFilterDataSource?
    public weak var searchLocationDataSource: SearchLocationDataSource?

    public weak var freeTextFilterDataSource: FreeTextFilterDataSource? {
        didSet { rootFilterViewController?.freeTextFilterDataSource = freeTextFilterDataSource }
    }

    public weak var freeTextFilterDelegate: FreeTextFilterDelegate? {
        didSet { rootFilterViewController?.freeTextFilterDelegate = freeTextFilterDelegate }
    }

    public var isLoading: Bool = false {
        didSet { updateLoading() }
    }

    // MARK: - Private properties

    private var selectionHasChanged = false
    private var bottomBottonClicked = false
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

    private func configure(with filterContainer: FilterContainer?) {
        guard let filterContainer = filterContainer else { return }

        selectionStore.syncSelection(with: filterContainer)

        if let rootFilterViewController = rootFilterViewController {
            rootFilterViewController.set(filterContainer: filterContainer)
        } else {
            rootFilterViewController = RootFilterViewController(
                filterContainer: filterContainer,
                selectionStore: selectionStore
            )
            rootFilterViewController?.rootDelegate = self
            rootFilterViewController?.freeTextFilterDataSource = freeTextFilterDataSource
            rootFilterViewController?.freeTextFilterDelegate = freeTextFilterDelegate
            setViewControllers([rootFilterViewController!], animated: false)
        }
    }
}

// MARK: - RootFilterViewControllerDelegate

extension CharcoalViewController: RootFilterViewControllerDelegate {
    func rootFilterViewControllerDidResetAllFilters(_ viewController: RootFilterViewController) {
        handleFilterSelectionChange(from: .resetAllButton)
    }

    func rootFilterViewController(_ viewController: RootFilterViewController, didRemoveFilter filter: Filter) {
        handleFilterSelectionChange(from: .removeFilterButton)
    }

    func rootFilterViewController(_ viewController: RootFilterViewController, didSelectInlineFilter filter: Filter) {
        handleFilterSelectionChange(from: .inlineFilter)
    }

    func rootFilterViewController(_ viewController: RootFilterViewController, didSelectFreeTextFilter filter: Filter) {
        handleFilterSelectionChange(from: .freeTextInput)
    }

    func rootFilterViewController(_ viewController: RootFilterViewController, didSelectVertical vertical: Vertical) {
        selectionDelegate?.charcoalViewController(self, didSelect: vertical)
    }

    private func handleFilterSelectionChange(from origin: SelectionChangeOrigin) {
        if let filterContainer = filterContainer {
            let queryItems = selectionStore.queryItems(for: filterContainer)
            selectionDelegate?.charcoalViewController(self, didChangeSelection: queryItems, origin: origin)
        }
    }
}

// MARK: - FilterViewControllerDelegate

extension CharcoalViewController: FilterViewControllerDelegate {
    func filterViewControllerWillBeginTextEditing(_ viewController: FilterViewController) {
        textEditingDelegate?.charcoalViewControllerWillBeginTextEditing(self)
    }

    func filterViewControllerWillEndTextEditing(_ viewController: FilterViewController) {
        textEditingDelegate?.charcoalViewControllerWillEndTextEditing(self)
    }

    func filterViewControllerDidPressBottomButton(_ viewController: FilterViewController) {
        if viewController === rootFilterViewController {
            selectionDelegate?.charcoalViewControllerDidPressShowResults(self)
        } else {
            bottomBottonClicked = true
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
            let mapViewController = MapFilterViewController(
                title: filter.title,
                latitudeFilter: latitudeFilter,
                longitudeFilter: longitudeFilter,
                radiusFilter: radiusFilter,
                locationNameFilter: locationNameFilter,
                selectionStore: selectionStore
            )

            mapViewController.mapDataSource = mapDataSource
            mapViewController.searchLocationDataSource = searchLocationDataSource

            pushViewController(mapViewController)
        case .list:
            guard !filter.subfilters.isEmpty else { break }

            let listViewController = ListFilterViewController(filter: filter, selectionStore: selectionStore)
            let showBottomButton = viewController === rootFilterViewController ? false : viewController.isShowingBottomButton

            listViewController.showBottomButton(showBottomButton, animated: false)
            pushViewController(listViewController)
        case .grid:
            guard !filter.subfilters.isEmpty else { break }

            let gridViewController = GridFilterViewController(filter: filter, selectionStore: selectionStore)
            gridViewController.showBottomButton(viewController.isShowingBottomButton, animated: false)

            pushViewController(gridViewController)
        case .external:
            selectionDelegate?.charcoalViewController(self, didSelectExternalFilterWithKey: filter.key, value: filter.value)
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
        defer {
            bottomBottonClicked = false
        }

        guard viewController === rootFilterViewController else {
            showBottomButtonIfNeeded()
            return
        }

        // Will return to root filters
        if selectionHasChanged, let filterContainer = filterContainer {
            let queryItems = selectionStore.queryItems(for: filterContainer)
            let origin: SelectionChangeOrigin = bottomBottonClicked ? .bottomButton : .navigation
            selectionDelegate?.charcoalViewController(self, didChangeSelection: queryItems, origin: origin)
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

    private func showBottomButtonIfNeeded() {
        for viewController in viewControllers where viewController !== rootFilterViewController {
            (viewController as? ListFilterViewController)?.showBottomButton(selectionHasChanged, animated: false)
        }
    }
}
