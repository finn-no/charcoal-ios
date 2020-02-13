//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import MapKit

class DrawMapAreaDemoViewController: DemoViewController {
    // MARK: - Private properties

    private let officeLocation = CLLocationCoordinate2D(latitude: 59.913833, longitude: 10.743777)

    private lazy var drawMapAreaView: DrawMapAreaView = {
        let view = DrawMapAreaView(centerCoordinate: officeLocation)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.mainBackground
        view.addSubview(drawMapAreaView)

        drawMapAreaView.fillInSuperview()
        modalPresentationStyle = .fullScreen
    }
}
