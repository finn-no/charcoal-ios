//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import MapKit
import UIKit

public class MapFilterViewController: FilterViewController {
    public var mapFilterViewManager: MapFilterViewManager?

    var searchLocationDataSource: SearchLocationDataSource?

    private lazy var mapFilterView: MapFilterView? = {
        guard let mapFilterViewManager = mapFilterViewManager else {
            return nil
        }
        let mapFilterView = MapFilterView(mapFilterViewManager: mapFilterViewManager)
        mapFilterView.searchBar = searchLocationViewController.searchBar
        return mapFilterView
    }()

    let filterInfo: FilterInfoType
    let dataSource: FilterDataSource

    lazy var searchLocationViewController: SearchLocationViewController = {
        let searchLocationViewController = SearchLocationViewController()
        searchLocationViewController.delegate = self
        searchLocationViewController.searchLocationDataSource = searchLocationDataSource
        return searchLocationViewController
    }()

    public init(filterInfo: FilterInfoType, dataSource: FilterDataSource, selectionDataSource: FilterSelectionDataSource, navigator: FilterNavigator?) {
        self.filterInfo = filterInfo
        self.dataSource = dataSource
        super.init(selectionDataSource: selectionDataSource, navigator: navigator)
        title = filterInfo.title
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        showApplyButton(true, animated: false)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let currentSelection = selectionDataSource.geoValue(for: filterInfo) else {
            return
        }
        mapFilterView?.setInitialSelection(latitude: currentSelection.latitude, longitude: currentSelection.longitude, radius: currentSelection.radius, locationName: currentSelection.locationName)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // TODO: This should be done when apply or back is pressed
        guard let mapFilterView = mapFilterView, let coordinate = mapFilterViewManager?.centerCoordinate else {
            return
        }
        selectionDataSource.setValue(latitude: coordinate.latitude, longitude: coordinate.longitude, radius: mapFilterView.currentRadius, locationName: nil, for: filterInfo)
    }

    private func setup() {
        view.backgroundColor = .milk
        mapFilterView?.translatesAutoresizingMaskIntoConstraints = false

        guard let mapFilterView = mapFilterView else {
            return
        }
        view.addSubview(mapFilterView)
        NSLayoutConstraint.activate([
            mapFilterView.topAnchor.constraint(equalTo: safeTopAnchor),
            mapFilterView.bottomAnchor.constraint(equalTo: applySelectionButton.topAnchor),
            mapFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

extension MapFilterViewController: SearchLocationViewControllerDelegate {
    public func searchLocationViewControllerDidSelectCurrentLocation(_ searchLocationViewController: SearchLocationViewController) {
        searchLocationViewController.willMove(toParent: nil)
        searchLocationViewController.view.removeFromSuperview()
        searchLocationViewController.removeFromParent()

        // TODO: start getting location
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
        mapFilterView?.searchBar = searchLocationViewController.searchBar
        mapFilterView?.setNeedsLayout()

        searchLocationViewController.willMove(toParent: nil)
        searchLocationViewController.view.removeFromSuperview()
        searchLocationViewController.removeFromParent()
    }

    public func searchLocationViewController(_ searchLocationViewController: SearchLocationViewController, didSelectLocation location: LocationInfo?) {
        mapFilterView?.searchBar = searchLocationViewController.searchBar
        searchLocationViewController.willMove(toParent: nil)
        searchLocationViewController.view.removeFromSuperview()
        searchLocationViewController.removeFromParent()

        if let location = location {
            mapFilterViewManager?.centerCoordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        }
    }
}
