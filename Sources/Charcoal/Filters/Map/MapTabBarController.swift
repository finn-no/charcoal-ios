//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

class MapTabBarController: UITabBarController {

    private let mapViewController: MapFilterViewController
    private let polygonMapViewController: MapPolygonFilterViewController
    private let selectionStore: FilterSelectionStore

    weak var filterDelegate: FilterViewControllerDelegate? {
        didSet {
            mapViewController.delegate = filterDelegate
            polygonMapViewController.delegate = filterDelegate
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
            polygonMapViewController.searchLocationDataSource = searchLocationDataSource
        }
    }

    private lazy var toggleViewControllersButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: .republish), style: .plain, target: self, action: #selector(toggleViewControllers))

    init(title: String, latitudeFilter: Filter, longitudeFilter: Filter, radiusFilter: Filter,
         locationNameFilter: Filter, bboxFilter: Filter, polygonFilter: Filter, selectionStore: FilterSelectionStore) {
        self.mapViewController = MapFilterViewController(title: title, latitudeFilter: latitudeFilter, longitudeFilter: longitudeFilter, radiusFilter: radiusFilter, locationNameFilter: locationNameFilter, selectionStore: selectionStore)
        self.polygonMapViewController = MapPolygonFilterViewController(title: title, latitudeFilter: latitudeFilter, longitudeFilter: longitudeFilter, locationNameFilter: locationNameFilter, bboxFilter: bboxFilter, polygonFilter: polygonFilter, selectionStore: selectionStore)
        self.selectionStore = selectionStore
        super.init(nibName: nil, bundle: nil)
        self.title = title
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        tabBar.isHidden = true
        navigationItem.rightBarButtonItem = toggleViewControllersButton
        self.viewControllers = [mapViewController, polygonMapViewController]
    }

    @objc private func toggleViewControllers() {
        selectionStore.clear()
        // TODO: Remember filter settings between toggles
        selectedIndex = (selectedIndex + 1) % 2
    }
}
