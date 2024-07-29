//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import MapKit
import Warp

class MapFilterDemoViewController: DemoViewController {
    // MARK: - Private properties

    private let officeLocation = CLLocationCoordinate2D(latitude: 59.913833, longitude: 10.743777)

    private lazy var mapView: MapRadiusFilterView = {
        let view = MapRadiusFilterView(radius: 40000, centerCoordinate: officeLocation)
        let searchBar = UISearchBar(frame: .zero)
        searchBar.placeholder = "Søk etter sted eller adresse"
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = Theme.mainBackground
        searchBar.smartQuotesType = .no
        searchBar.smartDashesType = .no
        view.searchBar = searchBar
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.mainBackground
        view.addSubview(mapView)

        NSLayoutConstraint.activate([
            mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mapView.heightAnchor.constraint(equalToConstant: 568),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Warp.Spacing.spacing200),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Warp.Spacing.spacing200),
        ])
    }
}
