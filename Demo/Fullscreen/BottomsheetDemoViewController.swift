//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit
import UIKit

class BottomsheetDemoViewController: UITableViewController {
    lazy var bottomsheetTransitioningDelegate: BotomsheetTransitioningDelegate = {
        let delegate = BotomsheetTransitioningDelegate(for: self)
        delegate.presentationControllerDelegate = self
        return delegate
    }()

    convenience init() {
        self.init(nibName: nil, bundle: nil)
        transitioningDelegate = bottomsheetTransitioningDelegate
        title = "Filtrer søket"
    }

    override func viewDidLoad() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = "Filter \(indexPath.row + 1)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sublevelViewController = BottomsheetDemoViewController()
        sublevelViewController.title = "Filter \(indexPath.row + 1)"
        
        navigationController?.pushViewController(sublevelViewController, animated: true)
    }
}

extension BottomsheetDemoViewController: BottomsheetPresentationControllerDelegate {
    func bottomsheetPresentationController(_ bottomsheetPresentationController: BottomsheetPresentationController, shouldBeginTransitionWithTranslation translation: CGPoint, from contentSizeMode: BottomsheetPresentationController.ContentSizeMode) -> Bool {
        switch contentSizeMode {
        case .expanded:
            let isDownwardTranslation = translation.y > 0.0
            
            if isDownwardTranslation {
                return tableView.isScrolledToTop
            } else {
                return false
            }
        default:
            return true
        }
    }
    
    
    func bottomsheetPresentationController(_ bottomsheetPresentationController: BottomsheetPresentationController, willTranstionFromContentSizeMode current: BottomsheetPresentationController.ContentSizeMode, to new: BottomsheetPresentationController.ContentSizeMode) {
        switch (current, new) {
        case (_, .compact):
            tableView.isScrollEnabled = false
        case (_, .expanded):
            tableView.isScrollEnabled = true
        }
    }
}

private extension UIScrollView {
    var isScrolledToTop: Bool {
        if #available(iOS 11.0, *) {
            return (contentOffset.y + adjustedContentInset.top).isZero
        } else {
            return (contentOffset.y + contentInset.top).isZero
        }
    }
}
