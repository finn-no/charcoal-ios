//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class FilterNavigationController: UINavigationController {
    public init(dataSource: FilterDataSource, selection: FilterSelectionDataSource, titleProvider: FilterSelectionTitleProvider) {
        let rootFilter = RootFilterViewController(filterDataSource: dataSource, selectionDataSource: selection, titleProvider: titleProvider)
        super.init(rootViewController: rootFilter)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
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
