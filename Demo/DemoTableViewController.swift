//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import FINNSetup

class DemoTableViewController: UIViewController {

    // MARK: - Private properties

    private let dataSource = DataSource()
    private var bottomSheet: BottomSheet?
    private let searchLocationDataSource = DemoSearchLocationDataSource()

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
        let row = dataSource.row(at: indexPath)
        var viewController = row.type.init()

        if let charcoalViewController = viewController as? CharcoalViewController {
            charcoalViewController.textEditingDelegate = self
            charcoalViewController.searchLocationDataSource = searchLocationDataSource
            charcoalViewController.filterContainer = row.setup?.filterContainer
            charcoalViewController.selectionDelegate = self
        }

        if row.usingBottomSheet {
            bottomSheet = BottomSheet(rootViewController: viewController)
            viewController = bottomSheet!
        }

        present(viewController, animated: true)
    }
}

extension DemoTableViewController: CharcoalViewControllerSelectionDelegate {
    func charcoalViewController(_ viewController: CharcoalViewController, didSelect vertical: Vertical) {
        viewController.isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            viewController.isLoading = false
        }
    }

    func charcoalViewController(_ viewController: CharcoalViewController, didSelectExternalFilterWithKey key: String, value: String?) {
        UIApplication.shared.open(URL(string: "https://finn.no")!, options: [:], completionHandler: nil)
    }

    func charcoalViewControllerDidPressShowResults(_ viewController: CharcoalViewController) {
        print("Did press show results")
    }

    func charcoalViewController(_ viewController: CharcoalViewController,
                                didChangeSelection selection: [URLQueryItem],
                                origin: SelectionChangeOrigin) {
        print("Selection did change by: \(origin)")
    }
}

extension DemoTableViewController: CharcoalViewControllerTextEditingDelegate {
    func charcoalViewControllerWillBeginTextEditing(_ viewController: CharcoalViewController) {
        bottomSheet?.state = .expanded
    }

    func charcoalViewControllerWillEndTextEditing(_ viewController: CharcoalViewController) {
        bottomSheet?.state = .compact
    }
}
