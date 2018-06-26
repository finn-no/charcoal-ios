//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterChildViewControllerDelegate: AnyObject {
    func filterChildViewController(filterChildViewController: FilterChildViewController, didUpdateFilterSelectionValue filterSelectionValue: FilterSelectionValue)
}

public protocol FilterChildViewController {
    var filterSelectionDelegate: FilterChildViewControllerDelegate? { get set }
    init?(filterInfo: FilterInfoType)
    func setSelectionValue(_ selectionValue: FilterSelectionValue)
    var controller: UIViewController { get }
}
