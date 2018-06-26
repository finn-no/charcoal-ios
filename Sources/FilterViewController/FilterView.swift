//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterViewDelegate: AnyObject {
    func filterView(filterView: FilterView, didUpdateFilterSelectionValue filterSelectionValue: FilterSelectionValue)
}

public class FilterView: UIView {
    public weak var delegate: FilterViewDelegate?

    public required init?(filterInfo: FilterInfoType) {
        fatalError("FilterView should be subclassed and is not intended for use as concrete type ")
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setSelectionValue(_ selectionValue: FilterSelectionValue) {}
}
