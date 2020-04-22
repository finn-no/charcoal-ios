//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

class MapTabBarController: UITabBarController {
    private let mapViewController: MapFilterViewController
    private let polygonMapViewController: MapPolygonFilterViewController?

    weak var filterDelegate: FilterViewControllerDelegate? {
        didSet {
            mapViewController.delegate = filterDelegate
            polygonMapViewController?.delegate = filterDelegate
        }
    }

    weak var mapDataSource: MapFilterDataSource? {
        didSet {
            mapViewController.mapDataSource = mapDataSource
        }
    }

    weak var searchLocationDataSource: SearchLocationDataSource? {
        didSet {
            mapViewController.searchLocationDataSource = searchLocationDataSource
            polygonMapViewController?.searchLocationDataSource = searchLocationDataSource
        }
    }

    private lazy var toggleButton: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(toggleViewControllers))
        buttonItem.setTitleTextAttributes([.font: UIFont.bodyStrong], for: .normal)
        return buttonItem
    }()

    private let selectionStore: FilterSelectionStore
    private let bboxFilter: Filter
    private let polygonFilter: Filter?

    init(title: String, latitudeFilter: Filter, longitudeFilter: Filter, radiusFilter: Filter,
         locationNameFilter: Filter, bboxFilter: Filter, polygonFilter: Filter?, selectionStore: FilterSelectionStore) {
        mapViewController = MapFilterViewController(title: title, latitudeFilter: latitudeFilter, longitudeFilter: longitudeFilter, radiusFilter: radiusFilter, locationNameFilter: locationNameFilter, selectionStore: selectionStore)

        if let polygonFilter = polygonFilter {
            polygonMapViewController = MapPolygonFilterViewController(title: title, locationNameFilter: locationNameFilter, bboxFilter: bboxFilter, polygonFilter: polygonFilter, selectionStore: selectionStore)
        } else {
            polygonMapViewController = nil
        }

        self.selectionStore = selectionStore
        self.bboxFilter = bboxFilter
        self.polygonFilter = polygonFilter
        super.init(nibName: nil, bundle: nil)
        self.title = title

        setup()
        mapViewController.mapFilterDelegate = self
        polygonMapViewController?.mapPolygonFilterDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        tabBar.isHidden = true

        guard let polygonMapViewController = polygonMapViewController else {
            viewControllers = [mapViewController]
            selectedViewController = mapViewController
            return
        }

        navigationItem.rightBarButtonItem = toggleButton
        viewControllers = [mapViewController, polygonMapViewController]

        if let polygonFilter = polygonFilter,
            selectionStore.isSelected(polygonFilter) || selectionStore.isSelected(bboxFilter) {
            selectedViewController = polygonMapViewController
        } else {
            selectedViewController = mapViewController
        }
        updateToggleButtonLabel()
    }

    @objc private func toggleViewControllers() {
        selectedIndex = (selectedIndex + 1) % 2
        updateToggleButtonLabel()
    }

    private func updateToggleButtonLabel() {
        toggleButton.title = selectedViewController == polygonMapViewController ? "map.radiusSearch.toggleButton.title".localized() : "map.polygonSearch.toggleButton.title".localized()
    }
}

// MARK: - MapFilterViewControllerDelegate

extension MapTabBarController: MapFilterViewControllerDelegate {
    func mapFilterViewControllerDidSelectFilter(_ mapFilterViewController: MapFilterViewController) {
        polygonMapViewController?.resetFilterValues()
    }
}

// MARK: - MapPolygonFilterViewControllerDelegate

extension MapTabBarController: MapPolygonFilterViewControllerDelegate {
    func mapPolygonFilterViewControllerDidSelectFilter(_ mapPolygonFilterViewController: MapPolygonFilterViewController) {
        mapViewController.resetFilterValues()
    }
}
