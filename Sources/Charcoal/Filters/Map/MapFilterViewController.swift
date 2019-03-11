//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import MapKit
import UIKit

final class MapFilterViewController: FilterViewController {
    private let mapFilterViewManager: MapFilterViewManager
    var searchLocationDataSource: SearchLocationDataSource? {
        didSet {
            searchLocationViewController.searchLocationDataSource = searchLocationDataSource
        }
    }

    private let latitudeFilter: Filter
    private let longitudeFilter: Filter
    private let radiusFilter: Filter
    private let locationNameFilter: Filter

    private lazy var mapFilterView: MapFilterView = {
        let mapFilterView = MapFilterView(
            mapFilterViewManager: mapFilterViewManager,
            radius: radius,
            centerPoint: coordinate
        )
        mapFilterView.searchBar = searchLocationViewController.searchBar
        mapFilterView.delegate = self
        mapFilterView.translatesAutoresizingMaskIntoConstraints = false
        return mapFilterView
    }()

    private lazy var searchLocationViewController: SearchLocationViewController = {
        let searchLocationViewController = SearchLocationViewController()
        searchLocationViewController.delegate = self
        return searchLocationViewController
    }()

    // MARK: - Init

    init(title: String, latitudeFilter: Filter, longitudeFilter: Filter, radiusFilter: Filter,
         locationNameFilter: Filter, selectionStore: FilterSelectionStore,
         mapFilterViewManager: MapFilterViewManager) {
        self.latitudeFilter = latitudeFilter
        self.longitudeFilter = longitudeFilter
        self.radiusFilter = radiusFilter
        self.locationNameFilter = locationNameFilter
        self.mapFilterViewManager = mapFilterViewManager
        super.init(title: title, selectionStore: selectionStore)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    public override func viewDidLoad() {
        super.viewDidLoad()
        bottomButton.buttonTitle = "apply_button_title".localized()
        view.backgroundColor = .milk

        showBottomButton(true, animated: false)
        setup()
    }

    override func filterBottomButtonView(_ filterBottomButtonView: FilterBottomButtonView, didTapButton button: UIButton) {
        radius = mapFilterView.currentRadius
        coordinate = mapFilterView.centerPoint
        locationName = mapFilterView.locationName
        super.filterBottomButtonView(filterBottomButtonView, didTapButton: button)
    }

    // MARK: - Setup

    private func setup() {
        view.addSubview(mapFilterView)

        NSLayoutConstraint.activate([
            mapFilterView.topAnchor.constraint(equalTo: view.topAnchor),
            mapFilterView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottomButton.height),
            mapFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func returnToMapFromLocationSearch() {
        mapFilterView.searchBar = searchLocationViewController.searchBar
        mapFilterView.setNeedsLayout()

        searchLocationViewController.willMove(toParent: nil)
        searchLocationViewController.view.removeFromSuperview()
        searchLocationViewController.removeFromParent()
    }
}

// MARK: - MapFilterViewDelegate

extension MapFilterViewController: MapFilterViewDelegate {
    func mapFilterView(_ mapFilterView: MapFilterView, didChangeRadius radius: Int) {
        self.radius = radius
    }

    func mapFilterView(_ mapFilterView: MapFilterView, didChangeLocationCoordinate coordinate: CLLocationCoordinate2D?) {
        self.coordinate = coordinate
    }

    func mapFilterView(_ mapFilterView: MapFilterView, didChangeLocationName locationName: String?) {
        self.locationName = locationName
    }
}

// MARK: - SearchLocationViewControllerDelegate

extension MapFilterViewController: SearchLocationViewControllerDelegate {
    public func searchLocationViewControllerDidSelectCurrentLocation(_ searchLocationViewController: SearchLocationViewController) {
        returnToMapFromLocationSearch()
        mapFilterViewManager.centerOnUserLocation()
    }

    public func searchLocationViewControllerShouldBePresented(_ searchLocationViewController: SearchLocationViewController) {
        // Add view controller as child view controller
        addChild(searchLocationViewController)
        view.addSubview(searchLocationViewController.view)
        searchLocationViewController.view.fillInSuperview()
        view.layoutIfNeeded()
        searchLocationViewController.didMove(toParent: self)
    }

    public func searchLocationViewControllerDidCancelSearch(_ searchLocationViewController: SearchLocationViewController) {
        returnToMapFromLocationSearch()
    }

    public func searchLocationViewController(_ searchLocationViewController: SearchLocationViewController, didSelectLocation location: LocationInfo?) {
        returnToMapFromLocationSearch()

        if let location = location {
            mapFilterViewManager.goToLocation(location)
        }
    }
}

// MARK: - Store

private extension MapFilterViewController {
    var radius: Int? {
        get {
            return selectionStore.value(for: radiusFilter)
        }
        set {
            selectionStore.setValue(newValue, for: radiusFilter)
        }
    }

    var coordinate: CLLocationCoordinate2D? {
        get {
            guard let latitude: Double = selectionStore.value(for: latitudeFilter) else {
                return nil
            }

            guard let longitude: Double = selectionStore.value(for: longitudeFilter) else {
                return nil
            }

            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set {
            selectionStore.setValue(newValue?.latitude, for: latitudeFilter)
            selectionStore.setValue(newValue?.longitude, for: longitudeFilter)
        }
    }

    var locationName: String? {
        get {
            return selectionStore.value(for: locationNameFilter)
        }
        set {
            selectionStore.setValue(newValue, for: locationNameFilter)
        }
    }
}
