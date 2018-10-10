//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterContainerViewControllerDelegate: AnyObject {
    func filterContainerViewController(filterContainerViewController: FilterContainerViewController, navigateTo filterInfo: FilterInfoType)
}

public protocol FilterContainerViewController: AnyObject {
    var filterSelectionDelegate: FilterContainerViewControllerDelegate? { get set }
    init?(filterInfo: FilterInfoType, selectionDataSource: FilterSelectionDataSource)
    var controller: UIViewController { get }
}
