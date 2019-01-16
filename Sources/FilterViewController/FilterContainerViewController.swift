//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterContainerViewControllerDelegate: AnyObject {
    func filterContainerViewController(filterContainerViewController: FilterContainerViewController, navigateTo filterInfo: FilterInfoType)
    func filterContainerViewControllerDidChangeSelection(filterContainerViewController: FilterContainerViewController)
    func filterContainerViewController(filterContainerViewController: FilterContainerViewController, navigateToMapFor filterInfo: FilterInfoType)
}

public protocol FilterContainerViewController: AnyObject {
    var filterSelectionDelegate: FilterContainerViewControllerDelegate? { get set }
    init?(filterInfo: FilterInfoType, dataSource: FilterDataSource, selectionDataSource: FilterSelectionDataSource)
    var controller: UIViewController { get }
}
