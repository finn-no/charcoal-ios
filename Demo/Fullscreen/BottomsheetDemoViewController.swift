//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit
import UIKit

class BottomsheetDemoViewController: UITableViewController {
    lazy var bottomsheetTransitioningDelegate: BotomsheetTransitioningDelegate = {
        return BotomsheetTransitioningDelegate(for: self)
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
