//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
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
    func charcoalViewController(_ viewController: CharcoalViewController,
                                didSelect selection: CharcoalViewController.MapSelection)
    func charcoalViewControllerDidConfigureInitialFilterContainer(_ viewController: CharcoalViewController)
}

public final class CharcoalViewController: UINavigationController {
    // MARK: - Public properties

    public var filterContainer: FilterContainer? {
        didSet {
            configure(with: filterContainer)
            if oldValue == nil {
                selectionDelegate?.charcoalViewControllerDidConfigureInitialFilterContainer(self)
            }
        }
    }

    public weak var textEditingDelegate: CharcoalViewControllerTextEditingDelegate?
    public weak var selectionDelegate: CharcoalViewControllerSelectionDelegate?
    public weak var searchLocationDataSource: SearchLocationDataSource?

    public weak var freeTextFilterDataSource: FreeTextFilterDataSource? {
        didSet { rootFilterViewController?.freeTextFilterDataSource = freeTextFilterDataSource }
    }

    public weak var freeTextFilterDelegate: FreeTextFilterDelegate? {
        didSet { rootFilterViewController?.freeTextFilterDelegate = freeTextFilterDelegate }
    }

    public var isLoading: Bool = false {
        didSet { rootFilterViewController?.showLoadingIndicator(isLoading) }
    }

    public var allSelectionTitles: [SelectionTitle] {
        var selectionTitles: [SelectionTitle] = []
        guard let allFilters = filterContainer?.allFilters else { return [] }
        for filter in allFilters {
            selectionTitles.append(contentsOf: selectionStore.titles(for: filter))
        }
        return selectionTitles
    }

    public var selectedFilters: [Filter] {
        return self.selectedFilters(in: filterContainer?.allFilters)
    }

    public enum MapSelection {
        case openPolygonSearch
        case openRadiusSearch
        case initialArea
    }

    // MARK: - Private properties

    private var selectionHasChanged = false
    private var bottomBottonClicked = false

    private lazy var selectionStore: FilterSelectionStore = {
        let store = FilterSelectionStore()
        store.delegate = self
        return store
    }()

    private var rootFilterViewController: RootFilterViewController?

    private var calloutOverlay: CalloutOverlay?

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        delegate = self
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let userDefaults = UserDefaults.standard

        if let text = filterContainer?.regionReformCalloutText, !userDefaults.regionReformCalloutShown {
            showCalloutOverlay(withText: text, andDirection: .down, constrainedToTopAnchor: navigationBar.bottomAnchor)
            userDefaults.regionReformCalloutShown = true
        }
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        calloutOverlay?.removeFromSuperview()
    }

    // MARK: - Public

    public func set(selection: Set<URLQueryItem>) {
        selectionStore.set(selection: selection)
        rootFilterViewController?.reloadFilters()
    }

    public func title(for filter: Filter) -> SelectionTitle? {
        let titles = selectionStore.titles(for: filter)
        guard titles.count == 1 else { return nil }
        return titles.first
    }

    public func isValid(_ filter: Filter) -> Bool {
        return selectionStore.isValid(filter)
    }

    public func queryItem(for filter: Filter) -> URLQueryItem? {
        selectionStore.queryItem(for: filter)
    }

    public func allQueryItems(for filter: Filter) -> [URLQueryItem]? {
        selectionStore.allQueryItems(for: filter)
    }

    // MARK: - Private

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

    private func setupNavigationBar() {
        navigationBar.isTranslucent = false
        navigationBar.backgroundColor = Theme.mainBackground

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBar.appearance().standardAppearance.copy()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = Theme.mainBackground

            navigationBar.standardAppearance = appearance
            navigationBar.compactAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationBar.shadowImage = UIImage()
        }
    }

    private func selectedFilters(in filters: [Filter]?) -> [Filter] {
        guard let filters = filters else { return [] }

        var selectedFilters: [Filter] = []
        for filter in filters {
            if selectionStore.isSelected(filter) {
                selectedFilters.append(filter)
            } else {
                selectedFilters.append(contentsOf: self.selectedFilters(in: filter.subfilters))
            }
        }
        return selectedFilters
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

    func rootFilterViewController(_ viewController: RootFilterViewController, didSelectSuggestionAt index: Int, filter: Filter) {
        handleFilterSelectionChange(from: .freeTextSuggestion(index: index))
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
    public func filterViewControllerWillBeginTextEditing(_ viewController: FilterViewController) {
        textEditingDelegate?.charcoalViewControllerWillBeginTextEditing(self)
    }

    public func filterViewControllerWillEndTextEditing(_ viewController: FilterViewController) {
        textEditingDelegate?.charcoalViewControllerWillEndTextEditing(self)
    }

    public func filterViewControllerWillPresentBottomButton(_ viewController: FilterViewController) {
        if UIDevice.current.userInterfaceIdiom == .pad, !UserDefaults.standard.bottomButtomCalloutShown {
            if viewController is ListFilterViewController ||
                viewController is RangeFilterViewController ||
                viewController is StepperFilterViewController ||
                viewController is GridFilterViewController {
                UserDefaults.standard.bottomButtomCalloutShown = true
                showCalloutOverlay(withText: "callout.bottomButton".localized(), andDirection: .down, constrainedToDirectionalAnchor: viewController.bottomButton.topAnchor)
            }
        }
    }

    public func filterViewControllerDidPressBottomButton(_ viewController: FilterViewController) {
        if viewController === rootFilterViewController {
            selectionDelegate?.charcoalViewControllerDidPressShowResults(self)
        } else {
            bottomBottonClicked = true
            popToRootViewController(animated: true)
        }
    }

    public func filterViewController(_ viewController: FilterViewController, didSelectFilter filter: Filter) {
        switch filter.kind {
        case .standard:
            guard !filter.subfilters.isEmpty else { break }

            let listViewController = ListFilterViewController(filter: filter, selectionStore: selectionStore)
            let showBottomButton = viewController === rootFilterViewController ? false : viewController.isShowingBottomButton

            listViewController.showBottomButton(showBottomButton, animated: false)
            pushViewController(listViewController)
        case .grid:
            guard !filter.subfilters.isEmpty else { break }

            let gridViewController = GridFilterViewController(filter: filter, selectionStore: selectionStore)

            pushViewController(gridViewController)
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
        case let .map(latitudeFilter, longitudeFilter, radiusFilter, locationNameFilter, bboxFilter, polygonFilter):
            let mapFilterViewController = MapFilterViewController(
                title: filter.title,
                latitudeFilter: latitudeFilter,
                longitudeFilter: longitudeFilter,
                radiusFilter: radiusFilter,
                locationNameFilter: locationNameFilter,
                bboxFilter: bboxFilter,
                polygonFilter: polygonFilter,
                selectionStore: selectionStore
            )
            mapFilterViewController.searchLocationDataSource = searchLocationDataSource
            mapFilterViewController.mapFilterDelegate = self
            pushViewController(mapFilterViewController)

            if polygonFilter != nil {
                showPolygonSearchCalloutIfNeeded()
            }

        case .external:
            selectionDelegate?.charcoalViewController(self, didSelectExternalFilterWithKey: filter.key, value: filter.value)
        }
    }

    private func pushViewController(_ viewController: FilterViewController) {
        viewController.delegate = self
        pushViewController(viewController, animated: true)
    }

    private func showPolygonSearchCalloutIfNeeded() {
        guard !UserDefaults.standard.polygonSearchCalloutShown else { return }
        UserDefaults.standard.polygonSearchCalloutShown = true
        showCalloutOverlay(
            withText: "map.polygonSearch.callout.title".localized(),
            andDirection: .up,
            andArrowAlignment: .right(15),
            constrainedToDirectionalAnchor: navigationBar.bottomAnchor
        )
    }
}

// MARK: - FilterSelectionStoreDelegate

extension CharcoalViewController: FilterSelectionStoreDelegate {
    public func filterSelectionStoreDidChange(_ selectionStore: FilterSelectionStore) {
        if topViewController !== rootFilterViewController {
            selectionHasChanged = true
        }

        rootFilterViewController?.updateResetButtonAvailability()
    }
}

// MARK: - UINavigationControllerDelegate

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

    private func showBottomButtonIfNeeded() {
        for viewController in viewControllers where viewController !== rootFilterViewController {
            (viewController as? ListFilterViewController)?.showBottomButton(selectionHasChanged, animated: false)
        }
    }
}

// MARK: - MapFilterViewControllerDelegate

extension CharcoalViewController: MapFilterViewControllerDelegate {
    func mapFilterViewController(_ mapFilterViewController: MapFilterViewController,
                                 didSelect selection: CharcoalViewController.MapSelection) {
        selectionDelegate?.charcoalViewController(self, didSelect: selection)
    }
}

// MARK: - CalloutOverlayDelegate

extension CharcoalViewController: CalloutOverlayDelegate {
    func calloutOverlayDidTapInside(_ bottomButtonCalloutOverlay: CalloutOverlay) {
        UIView.animate(withDuration: 0.3, animations: {
            self.calloutOverlay?.alpha = 0
        }, completion: { _ in
            self.calloutOverlay?.removeFromSuperview()
            self.calloutOverlay = nil
        })
    }

    private func showCalloutOverlay(withText text: String,
                                    andDirection direction: CalloutView.Direction,
                                    andArrowAlignment arrowAlignment: CalloutView.ArrowAlignment = .center,
                                    constrainedToDirectionalAnchor directionalAnchor: NSLayoutYAxisAnchor? = nil,
                                    constrainedToTopAnchor topAnchor: NSLayoutYAxisAnchor? = nil) {
        calloutOverlay = CalloutOverlay(direction: direction, arrowAlignment: arrowAlignment)

        if let calloutOverlay = calloutOverlay {
            calloutOverlay.delegate = self
            calloutOverlay.translatesAutoresizingMaskIntoConstraints = false
            calloutOverlay.alpha = 0

            view.addSubview(calloutOverlay)

            if let topAnchor = topAnchor {
                calloutOverlay.configure(withText: text, calloutTopAnchor: topAnchor)
            } else if let directionalAnchor = directionalAnchor {
                calloutOverlay.configure(withText: text, calloutAnchor: directionalAnchor)
            }

            calloutOverlay.fillInSuperview()

            UIView.animate(withDuration: 0.3, delay: 0.5, options: [], animations: { [weak self] in
                self?.calloutOverlay?.alpha = 1
            }, completion: nil)
        }
    }
}

// MARK: - UserDefaults

private extension UserDefaults {
    var regionReformCalloutShown: Bool {
        get { return bool(forKey: "Charcoal." + #function) }
        set { set(newValue, forKey: "Charcoal." + #function) }
    }

    var bottomButtomCalloutShown: Bool {
        get { return bool(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }

    var polygonSearchCalloutShown: Bool {
        get { return bool(forKey: "Charcoal." + #function) }
        set { set(newValue, forKey: "Charcoal." + #function) }
    }
}
