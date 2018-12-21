//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import MapKit
import UIKit

public class MapFilterViewController: UIViewController {
    public var filterSelectionDelegate: FilterContainerViewControllerDelegate?

    public var mapFilterViewManager: MapFilterViewManager?

    private lazy var mapFilterView: MapFilterView? = {
        guard let mapFilterViewManager = mapFilterViewManager else {
            return nil
        }
        return MapFilterView(mapFilterViewManager: mapFilterViewManager)
    }()

    let filterInfo: FilterInfoType
    let dataSource: FilterDataSource
    let selectionDataSource: FilterSelectionDataSource

    public required init?(filterInfo: FilterInfoType, dataSource: FilterDataSource, selectionDataSource: FilterSelectionDataSource) {
        self.filterInfo = filterInfo
        self.dataSource = dataSource
        self.selectionDataSource = selectionDataSource
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
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
            mapFilterView.bottomAnchor.constraint(equalTo: safeBottomAnchor),
            mapFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .mediumLargeSpacing),
            mapFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.mediumLargeSpacing),
        ])
    }
}

extension MapFilterViewController: FilterContainerViewController {
    public var controller: UIViewController {
        return self
    }
}
