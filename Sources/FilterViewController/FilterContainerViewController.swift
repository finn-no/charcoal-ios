//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol ScrollableContainerViewController: AnyObject {
    var mainScrollableView: UIScrollView { get }
    var isMainScrollableViewScrolledToTop: Bool { get }
}

public extension ScrollableContainerViewController {
    var isMainScrollableViewScrolledToTop: Bool {
        let scrollPos: CGFloat
        if #available(iOS 11.0, *) {
            scrollPos = (mainScrollableView.contentOffset.y + mainScrollableView.adjustedContentInset.top)
        } else {
            scrollPos = (mainScrollableView.contentOffset.y + mainScrollableView.contentInset.top)
        }
        return scrollPos < 1
    }
}

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
