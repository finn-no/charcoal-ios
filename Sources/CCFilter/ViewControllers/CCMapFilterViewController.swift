//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import MapKit
import UIKit

class CCMapFilterViewController: CCViewController {

    // MARK: - Public properties

    var mapFilterViewManager: MapFilterViewManager?
    var searchLocationDataSource: SearchLocationDataSource?

    var mapNode: CCMapFilterNode? {
        return filterNode as? CCMapFilterNode
    }

    // MARK: - Private properties

    private lazy var mapFilterView: MapFilterView? = {
        guard let mapFilterViewManager = mapFilterViewManager else {
            return nil
        }
        let mapFilterView = MapFilterView(mapFilterViewManager: mapFilterViewManager)
        mapFilterView.searchBar = searchLocationViewController.searchBar
        mapFilterView.delegate = self
        return mapFilterView
    }()

    private lazy var searchLocationViewController: SearchLocationViewController = {
        let searchLocationViewController = SearchLocationViewController()
        searchLocationViewController.delegate = self
        searchLocationViewController.searchLocationDataSource = searchLocationDataSource
        return searchLocationViewController
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        bottomButton.buttonTitle = "Bruk"
        setup()
    }
}

extension CCMapFilterViewController: MapFilterViewDelegate {
    func mapFilterView(_ mapFilterView: MapFilterView, didChangeRadius radius: Int) {
        if let radiusNode = mapNode?.radiusNode {
            selectionStore.select(node: radiusNode, value: String(radius))
        }
    }

    func mapFilterView(_ mapFilterView: MapFilterView, didChangeLocation location: CLLocationCoordinate2D) {
        if let latitudeNode = mapNode?.latitudeNode {
            selectionStore.select(node: latitudeNode, value: String(location.latitude))
        }

        if let longitudeNode = mapNode?.longitudeNode {
            selectionStore.select(node: longitudeNode, value: String(location.latitude))
        }
    }
}

extension CCMapFilterViewController: SearchLocationViewControllerDelegate {
    public func searchLocationViewControllerDidSelectCurrentLocation(_ searchLocationViewController: SearchLocationViewController) {
        returnToMapFromLocationSearch()
        mapFilterViewManager?.centerOnUserLocation()
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
            mapFilterViewManager?.goToLocation(location)
        }
    }
}

private extension CCMapFilterViewController {
    func setup() {
        view.backgroundColor = .milk
        mapFilterView?.translatesAutoresizingMaskIntoConstraints = false

        guard let mapFilterView = mapFilterView else {
            return
        }
        view.addSubview(mapFilterView)
        NSLayoutConstraint.activate([
            mapFilterView.topAnchor.constraint(equalTo: view.topAnchor),
            mapFilterView.bottomAnchor.constraint(equalTo: bottomButton.topAnchor),
            mapFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    func returnToMapFromLocationSearch() {
        mapFilterView?.searchBar = searchLocationViewController.searchBar
        mapFilterView?.setNeedsLayout()

        searchLocationViewController.willMove(toParent: nil)
        searchLocationViewController.view.removeFromSuperview()
        searchLocationViewController.removeFromParent()
    }
}
