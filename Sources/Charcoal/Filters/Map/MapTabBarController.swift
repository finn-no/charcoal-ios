//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

protocol MapTabBarControllerDelegate: AnyObject {
    func mapTabBarController(_ mapTabBarController: MapTabBarController, didSelect selection: CharcoalViewController.PolygonSelection)
}

class MapTabBarController: UITabBarController {
    private let mapRadiusFilterViewController: MapRadiusFilterViewController
    private let mapPolygonFilterViewController: MapPolygonFilterViewController?

    weak var tabBarDelegate: MapTabBarControllerDelegate?

    weak var filterDelegate: FilterViewControllerDelegate? {
        didSet {
            mapRadiusFilterViewController.delegate = filterDelegate
            mapPolygonFilterViewController?.delegate = filterDelegate
        }
    }

    weak var searchLocationDataSource: SearchLocationDataSource? {
        didSet {
            mapRadiusFilterViewController.searchLocationDataSource = searchLocationDataSource
            mapPolygonFilterViewController?.searchLocationDataSource = searchLocationDataSource
        }
    }

    private lazy var toggleButton: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(toggleViewControllers))
        buttonItem.setTitleTextAttributes([.font: UIFont.bodyStrong], for: .normal)
        return buttonItem
    }()

    private let selectionStore: FilterSelectionStore
    private let bboxFilter: Filter?
    private let polygonFilter: Filter?

    init(title: String, latitudeFilter: Filter, longitudeFilter: Filter, radiusFilter: Filter,
         locationNameFilter: Filter, bboxFilter: Filter?, polygonFilter: Filter?, selectionStore: FilterSelectionStore) {
        mapRadiusFilterViewController = MapRadiusFilterViewController(title: title, latitudeFilter: latitudeFilter, longitudeFilter: longitudeFilter, radiusFilter: radiusFilter, locationNameFilter: locationNameFilter, selectionStore: selectionStore)

        if let bboxFilter = bboxFilter,
            let polygonFilter = polygonFilter {
            mapPolygonFilterViewController = MapPolygonFilterViewController(title: title, locationNameFilter: locationNameFilter, bboxFilter: bboxFilter, polygonFilter: polygonFilter, selectionStore: selectionStore)
        } else {
            mapPolygonFilterViewController = nil
        }

        self.selectionStore = selectionStore
        self.bboxFilter = bboxFilter
        self.polygonFilter = polygonFilter
        super.init(nibName: nil, bundle: nil)
        self.title = title

        setup()
        mapRadiusFilterViewController.mapRadiusFilterDelegate = self
        mapPolygonFilterViewController?.mapPolygonFilterDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        tabBar.isHidden = true

        guard let polygonMapViewController = mapPolygonFilterViewController else {
            viewControllers = [mapRadiusFilterViewController]
            selectedViewController = mapRadiusFilterViewController
            return
        }

        navigationItem.rightBarButtonItem = toggleButton
        viewControllers = [mapRadiusFilterViewController, polygonMapViewController]

        if let bboxFilter = bboxFilter,
            let polygonFilter = polygonFilter,
            selectionStore.isSelected(polygonFilter) || selectionStore.isSelected(bboxFilter) {
            selectedViewController = polygonMapViewController
        } else {
            selectedViewController = mapRadiusFilterViewController
        }
        updateToggleButtonLabel()
    }

    @objc private func toggleViewControllers() {
        selectedIndex = (selectedIndex + 1) % 2
        updateToggleButtonLabel()

        if selectedViewController == mapPolygonFilterViewController {
            tabBarDelegate?.mapTabBarController(self, didSelect: .openPolygonSearch)
        }
    }

    private func updateToggleButtonLabel() {
        toggleButton.title = selectedViewController == mapPolygonFilterViewController ? "map.radiusSearch.toggleButton.title".localized() : "map.polygonSearch.toggleButton.title".localized()
    }
}

// MARK: - MapRadiusFilterViewControllerDelegate

extension MapTabBarController: MapRadiusFilterViewControllerDelegate {
    func mapRadiusFilterViewControllerDidSelectFilter(_ mapRadiusFilterViewController: MapRadiusFilterViewController) {
        mapPolygonFilterViewController?.resetFilterValues()
    }
}

// MARK: - MapPolygonFilterViewControllerDelegate

extension MapTabBarController: MapPolygonFilterViewControllerDelegate {
    func mapPolygonFilterViewController(_ mapPolygonFilterViewController: MapPolygonFilterViewController, didSelect selection: CharcoalViewController.PolygonSelection) {
        tabBarDelegate?.mapTabBarController(self, didSelect: selection)
    }

    func mapPolygonFilterViewControllerDidSelectFilter(_ mapPolygonFilterViewController: MapPolygonFilterViewController) {
        mapRadiusFilterViewController.resetFilterValues()
    }
}
