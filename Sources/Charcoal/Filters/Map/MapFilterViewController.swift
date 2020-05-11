//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

protocol MapFilterViewControllerDelegate: AnyObject {
    func mapFilterViewController(_ mapFilterViewController: MapFilterViewController,
                                 didSelect selection: CharcoalViewController.MapSelection)
}

protocol ToggleFilter: AnyObject {
    func resetFilterValues()
    func updateFilterValues()
}

class MapFilterViewController: FilterViewController {
    private let mapRadiusFilterViewController: MapRadiusFilterViewController
    private let mapPolygonFilterViewController: MapPolygonFilterViewController?
    private var selectedViewController: UIViewController

    weak var mapFilterDelegate: MapFilterViewControllerDelegate?

    weak var searchLocationDataSource: SearchLocationDataSource? {
        didSet {
            mapRadiusFilterViewController.searchLocationDataSource = searchLocationDataSource
            mapPolygonFilterViewController?.searchLocationDataSource = searchLocationDataSource
        }
    }

    private lazy var toggleButton: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(
            title: nil,
            style: .plain,
            target: self,
            action: #selector(toggleViewControllers)
        )
        buttonItem.setTitleTextAttributes([.font: UIFont.bodyStrong], for: .normal)
        return buttonItem
    }()

    private lazy var mapContainerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let bboxFilter: Filter?
    private let polygonFilter: Filter?

    init(title: String, latitudeFilter: Filter, longitudeFilter: Filter, radiusFilter: Filter,
         locationNameFilter: Filter, bboxFilter: Filter?, polygonFilter: Filter?, selectionStore: FilterSelectionStore) {
        mapRadiusFilterViewController =
            MapRadiusFilterViewController(
                latitudeFilter: latitudeFilter,
                longitudeFilter: longitudeFilter,
                radiusFilter: radiusFilter,
                locationNameFilter: locationNameFilter,
                selectionStore: selectionStore
            )
        selectedViewController = mapRadiusFilterViewController

        if let bboxFilter = bboxFilter,
            let polygonFilter = polygonFilter {
            mapPolygonFilterViewController =
                MapPolygonFilterViewController(
                    locationNameFilter: locationNameFilter,
                    bboxFilter: bboxFilter,
                    polygonFilter: polygonFilter,
                    selectionStore: selectionStore
                )
        } else {
            mapPolygonFilterViewController = nil
        }

        self.bboxFilter = bboxFilter
        self.polygonFilter = polygonFilter
        super.init(title: title, selectionStore: selectionStore)
        self.title = title

        mapRadiusFilterViewController.delegate = self
        mapPolygonFilterViewController?.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        bottomButton.buttonTitle = "applyButton".localized()
        view.backgroundColor = Theme.mainBackground

        showBottomButton(true, animated: false)
        setup()
    }

    override func filterBottomButtonView(_ filterBottomButtonView: FilterBottomButtonView,
                                         didTapButton button: UIButton) {
        guard let mapPolygonFilterViewController = mapPolygonFilterViewController else {
            mapRadiusFilterViewController.updateFilterValues()
            super.filterBottomButtonView(filterBottomButtonView, didTapButton: button)
            return
        }

        let inactiveViewController = selectedViewController == mapPolygonFilterViewController ?
            mapRadiusFilterViewController : mapPolygonFilterViewController

        if let inactiveViewController = inactiveViewController as? ToggleFilter,
            let selectedViewController = selectedViewController as? ToggleFilter {
            inactiveViewController.resetFilterValues()
            selectedViewController.updateFilterValues()
        }
        super.filterBottomButtonView(filterBottomButtonView, didTapButton: button)
    }

    // MARK: - Setup

    private func setup() {
        view.insertSubview(mapContainerView, belowSubview: bottomButton)

        NSLayoutConstraint.activate([
            mapContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            mapContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapContainerView.bottomAnchor.constraint(equalTo: bottomButton.topAnchor),
        ])

        guard let mapPolygonFilterViewController = mapPolygonFilterViewController else {
            display(mapRadiusFilterViewController)
            return
        }

        navigationItem.rightBarButtonItem = toggleButton

        if let bboxFilter = bboxFilter,
            let polygonFilter = polygonFilter,
            selectionStore.isSelected(polygonFilter) || selectionStore.isSelected(bboxFilter) {
            selectedViewController = mapPolygonFilterViewController
        } else {
            selectedViewController = mapRadiusFilterViewController
        }

        display(selectedViewController)
        updateToggleButtonLabel()
    }

    private func display(_ childViewController: UIViewController) {
        guard childViewController.parent == nil else { return }

        addChild(childViewController)
        childViewController.view.frame = mapContainerView.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapContainerView.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
    }

    // MARK: - Private methods

    @objc private func toggleViewControllers() {
        guard let mapPolygonFilterViewController = mapPolygonFilterViewController else { return }

        bottomButton.isEnabled = true

        selectedViewController.remove()
        selectedViewController = selectedViewController == mapRadiusFilterViewController ?
            mapPolygonFilterViewController : mapRadiusFilterViewController
        display(selectedViewController)
        updateToggleButtonLabel()

        let openedSearch: CharcoalViewController.MapSelection =
            selectedViewController == mapRadiusFilterViewController ? .openRadiusSearch : .openPolygonSearch
        mapFilterDelegate?.mapFilterViewController(self, didSelect: openedSearch)
    }

    private func updateToggleButtonLabel() {
        toggleButton.title = selectedViewController == mapPolygonFilterViewController ?
            "map.radiusSearch.toggleButton.title".localized() :
            "map.polygonSearch.toggleButton.title".localized()
    }
}

// MARK: - MapRadiusFilterViewControllerDelegate

extension MapFilterViewController: MapRadiusFilterViewControllerDelegate {
    func mapRadiusFilterViewControllerWillBeginTextEditing(_ mapRadiusFilterViewController: MapRadiusFilterViewController) {
        delegate?.filterViewControllerWillBeginTextEditing(self)
    }

    func mapRadiusFilterViewControllerWillEndTextEditing(_ mapRadiusFilterViewController: MapRadiusFilterViewController) {
        delegate?.filterViewControllerWillEndTextEditing(self)
    }

    func mapRadiusFilterViewControllerDidChangeRadius(_ mapRadiusFilterViewController: MapRadiusFilterViewController) {
        enableSwipeBack(true)
    }
}

// MARK: - MapPolygonFilterViewControllerDelegate

extension MapFilterViewController: MapPolygonFilterViewControllerDelegate {
    func mapPolygonFilterViewController(_ mapPolygonFilterViewController: MapPolygonFilterViewController,
                                        searchIsEnabled: Bool) {
        bottomButton.isEnabled = searchIsEnabled
    }

    func mapPolygonFilterViewControllerWillBeginTextEditing(_ mapPolygonFilterViewController: MapPolygonFilterViewController) {
        delegate?.filterViewControllerWillBeginTextEditing(self)
    }

    func mapPolygonFilterViewControllerWillEndTextEditing(_ mapPolygonFilterViewController: MapPolygonFilterViewController) {
        delegate?.filterViewControllerWillEndTextEditing(self)
    }

    func mapPolygonFilterViewControllerDidSelectInitialArea(_ mapPolygonFilterViewController: MapPolygonFilterViewController) {
        mapFilterDelegate?.mapFilterViewController(self, didSelect: .initialArea)
    }

    func mapPolygonFilterViewControllerDidSelectFilter(_ mapPolygonFilterViewController: MapPolygonFilterViewController) {
        mapRadiusFilterViewController.resetFilterValues()
    }
}
