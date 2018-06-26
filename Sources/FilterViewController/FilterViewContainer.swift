//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterViewContainerDelegate: AnyObject {
    func filterViewContainer(filterViewContainer: FilterViewContainer, didUpdateFilterSelectionValue filterSelectionValue: FilterSelectionValue)
}

public class FilterViewContainer: UIViewController {
    public weak var delegate: FilterViewContainerDelegate?

    public required init?(filterInfo: FilterInfoType) {
        fatalError("FilterViewContainer should be subclassed and is not intended for use as concrete type ")
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public func setSelectionValue(_ selectionValue: FilterSelectionValue) {}
}
