//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public protocol FilterRootViewControllerDelegate: AnyObject {
    func filterRootViewControllerDidSelectShowResults(_ filterRootViewController: FilterRootViewController)
    func filterRootViewController(_ filterRootViewController: FilterRootViewController, didSelectFilterAt indexPath: IndexPath)
    func filterRootViewController(_ filterRootViewController: FilterRootViewController, didSelectContextFilterAt indexPath: IndexPath)
}
