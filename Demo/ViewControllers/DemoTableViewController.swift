//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import FINNSetup

class DemoTableViewController: UIViewController {

    // MARK: - Private properties

    private let dataSource = DataSource()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .secondaryBlue
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.register(DemoTableViewCell.self)
        tableView.separatorStyle = .none
        return tableView
    }()

    // MARK: - Life cycle

    override func loadView() {
        view = tableView
    }
}

// MARK: - UITableViewDelegate

extension DemoTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var viewController = dataSource.viewController(for: indexPath)

        if let charcoalViewController = viewController as? CharcoalViewController {
            viewController = BottomSheet(rootViewController: charcoalViewController)
        }

        present(viewController, animated: true)
    }
}
