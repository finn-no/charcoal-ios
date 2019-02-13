//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import MapKit
import UIKit

final class CCMapFilterViewController: CCViewController {
    private let mapFilterViewManager: MapFilterViewManager
    private let searchLocationDataSource: SearchLocationDataSource?
    private let mapFilterNode: CCMapFilterNode

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
        searchLocationViewController.searchLocationDataSource = searchLocationDataSource
        return searchLocationViewController
    }()

    // MARK: - Init

    init(mapFilterNode: CCMapFilterNode, selectionStore: FilterSelectionStore,
         mapFilterViewManager: MapFilterViewManager, searchLocationDataSource: SearchLocationDataSource?) {
        self.mapFilterNode = mapFilterNode
        self.mapFilterViewManager = mapFilterViewManager
        self.searchLocationDataSource = searchLocationDataSource
        super.init(filterNode: mapFilterNode, selectionStore: selectionStore)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        bottomButton.buttonTitle = "apply_button_title".localized()
        view.backgroundColor = .milk

        showBottomButton(true, animated: false)
        setup()
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

extension CCMapFilterViewController: MapFilterViewDelegate {
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

extension CCMapFilterViewController: SearchLocationViewControllerDelegate {
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

private extension CCMapFilterViewController {
    var radius: Int? {
        get {
            return Int(selectionStore.value(for: mapFilterNode.radiusNode))
        }
        set {
            selectionStore.select(node: mapFilterNode.radiusNode, value: newValue.map(String.init))
        }
    }

    var coordinate: CLLocationCoordinate2D? {
        get {
            guard let latitude = selectionStore.value(for: mapFilterNode.latitudeNode).flatMap(Double.init) else {
                return nil
            }

            guard let longitude = selectionStore.value(for: mapFilterNode.longitudeNode).flatMap(Double.init) else {
                return nil
            }

            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set {
            selectionStore.select(node: mapFilterNode.latitudeNode, value: newValue.map({ String($0.latitude) }))
            selectionStore.select(node: mapFilterNode.longitudeNode, value: newValue.map({ String($0.longitude) }))
        }
    }

    var locationName: String? {
        get {
            return selectionStore.value(for: mapFilterNode.geoLocationNode)
        }
        set {
            selectionStore.select(node: mapFilterNode.geoLocationNode, value: newValue)
        }
    }
}
