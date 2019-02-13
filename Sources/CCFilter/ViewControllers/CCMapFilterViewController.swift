//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import MapKit
import UIKit

class CCMapFilterViewController: CCViewController {

    // MARK: - Public properties

    var mapFilterViewManager: MapFilterViewManager? {
        didSet {
            setup()
        }
    }

    var searchLocationDataSource: SearchLocationDataSource? {
        didSet {
            searchLocationViewController.searchLocationDataSource = searchLocationDataSource
        }
    }

    // MARK: - Private properties

    private let mapFilterNode: CCMapFilterNode
    private var mapFilterView: MapFilterView?

    private lazy var searchLocationViewController: SearchLocationViewController = {
        let searchLocationViewController = SearchLocationViewController()
        searchLocationViewController.delegate = self
        return searchLocationViewController
    }()

    // MARK: - Setup

    init(mapFilterNode: CCMapFilterNode) {
        self.mapFilterNode = mapFilterNode
        super.init(filterNode: mapFilterNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        bottomButton.buttonTitle = "apply_button_title".localized()
        view.backgroundColor = .milk
        showBottomButton(true, animated: false)
    }
}

extension CCMapFilterViewController: MapFilterViewDelegate {
    func mapFilterView(_ mapFilterView: MapFilterView, didChangeRadius radius: Int) {
        let radiusNode = mapFilterNode.radiusNode
        radiusNode.value = String(radius)
        radiusNode.isSelected = true
    }

    func mapFilterView(_ mapFilterView: MapFilterView, didChangeLocation location: CLLocationCoordinate2D) {
        let latitudeNode = mapFilterNode.latitudeNode
        latitudeNode.value = String(location.latitude)
        latitudeNode.isSelected = true

        let longitudeNode = mapFilterNode.longitudeNode
        longitudeNode.value = String(location.longitude)
        longitudeNode.isSelected = true
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
    func createMapFilterView(with manager: MapFilterViewManager) -> MapFilterView {
        let mapFilterView = MapFilterView(mapFilterViewManager: manager)
        mapFilterView.searchBar = searchLocationViewController.searchBar
        mapFilterView.delegate = self
        mapFilterView.translatesAutoresizingMaskIntoConstraints = false
        return mapFilterView
    }

    func setup() {
        guard let manager = mapFilterViewManager else {
            return
        }

        let mapView = mapFilterView ?? createMapFilterView(with: manager)
        mapFilterView = mapView

        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottomButton.height),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
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
