//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class FilterNavigationController: UINavigationController {

    // MARK: - Public properties

    public weak var filterDelegate: FilterRootViewControllerDelegate? {
        get { return rootFilterViewController.delegate }
        set { rootFilterViewController.delegate = newValue }
    }

    public var mapFilterViewManager: MapFilterViewManager? {
        get { return rootFilterViewController.mapFilterViewManager }
        set { rootFilterViewController.mapFilterViewManager = newValue }
    }

    public var searchLocationDataSource: SearchLocationDataSource? {
        get { return rootFilterViewController.searchLocationDataSource }
        set { rootFilterViewController.searchLocationDataSource = newValue }
    }

    // MARK: - Private properties

    private let rootFilterViewController: RootFilterViewController

    // MARK: - Setup

    public init(dataSource: FilterDataSource, selection: FilterSelectionDataSource, titleProvider: FilterSelectionTitleProvider) {
        rootFilterViewController = RootFilterViewController(filterDataSource: dataSource, selectionDataSource: selection, titleProvider: titleProvider)
        super.init(nibName: nil, bundle: nil)
        setViewControllers([rootFilterViewController], animated: false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
        navigationBar.shadowImage = UIImage()
    }
}

extension FilterNavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let slider = touch.view as? UISlider, slider.isEnabled, !slider.isHidden {
            return false
        }
        return true
    }
}
