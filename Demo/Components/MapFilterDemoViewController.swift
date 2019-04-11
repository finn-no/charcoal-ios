//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import MapKit

class MapFilterDemoViewController: DemoViewController {
    private let officeLocation = CLLocationCoordinate2D(latitude: 59.913833, longitude: 10.743777)
    private lazy var mapView: MapFilterView = {
        let view = MapFilterView(radius: 40000, centerCoordinate: officeLocation)
        let searchBar = UISearchBar(frame: .zero)
        searchBar.placeholder = "Søk etter sted eller adresse"
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .white
        view.searchBar = searchBar
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(mapView)

        NSLayoutConstraint.activate([
            mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mapView.heightAnchor.constraint(equalToConstant: 568),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .mediumLargeSpacing),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.mediumLargeSpacing),
        ])
    }
}
