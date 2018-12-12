//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public class MapFilterViewController: UIViewController {
    private let mapFilterViewManager: MapFilterViewManager

    private lazy var mapFilterView: MapFilterView = {
        return MapFilterView(mapFilterViewManager: mapFilterViewManager)
    }()

    public init(mapFilterViewManager: MapFilterViewManager) {
        self.mapFilterViewManager = mapFilterViewManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        view.backgroundColor = .milk
        mapFilterView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapFilterView)

        NSLayoutConstraint.activate([
            mapFilterView.topAnchor.constraint(equalTo: safeTopAnchor),
            mapFilterView.bottomAnchor.constraint(equalTo: safeBottomAnchor),
            mapFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .mediumLargeSpacing),
            mapFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.mediumLargeSpacing),
        ])
    }
}
