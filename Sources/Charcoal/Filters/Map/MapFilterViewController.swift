//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

protocol MapFilterViewControllerDelegate: AnyObject {
    func mapFilterViewController(_ mapFilterViewController: MapFilterViewController,
                                 didSelect selection: CharcoalViewController.MapSelection)
}

class MapFilterViewController: UIViewController {
    private let mapRadiusFilterViewController: MapRadiusFilterViewController
    private let mapPolygonFilterViewController: MapPolygonFilterViewController?
    private var selectedViewController: UIViewController

    weak var mapFilterDelegate: MapFilterViewControllerDelegate?

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
        mapRadiusFilterViewController =
            MapRadiusFilterViewController(
                title: title,
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
                    title: title,
                    locationNameFilter: locationNameFilter,
                    bboxFilter: bboxFilter,
                    polygonFilter: polygonFilter,
                    selectionStore: selectionStore
                )
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
        guard let mapPolygonFilterViewController = mapPolygonFilterViewController else {
            add(mapRadiusFilterViewController)
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

        add(selectedViewController)
        updateToggleButtonLabel()
    }

    @objc private func toggleViewControllers() {
        guard let mapPolygonFilterViewController = mapPolygonFilterViewController else { return }

        selectedViewController.remove()
        selectedViewController = selectedViewController == mapRadiusFilterViewController ?
            mapPolygonFilterViewController : mapRadiusFilterViewController
        add(selectedViewController)
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
    func mapRadiusFilterViewControllerDidSelectFilter(_ mapRadiusFilterViewController: MapRadiusFilterViewController) {
        mapPolygonFilterViewController?.resetFilterValues()
    }
}

// MARK: - MapPolygonFilterViewControllerDelegate

extension MapFilterViewController: MapPolygonFilterViewControllerDelegate {
    func mapPolygonFilterViewControllerDidSelectInitialArea(_ mapPolygonFilterViewController: MapPolygonFilterViewController) {
        mapFilterDelegate?.mapFilterViewController(self, didSelect: .initialArea)
    }

    func mapPolygonFilterViewControllerDidSelectFilter(_ mapPolygonFilterViewController: MapPolygonFilterViewController) {
        mapRadiusFilterViewController.resetFilterValues()
    }
}
