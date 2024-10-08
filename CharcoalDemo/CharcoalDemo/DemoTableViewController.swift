//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import FinniversKit

class DemoTableViewController: UIViewController {
    // MARK: - Private properties

    private let dataSource = DataSource()
    private var bottomSheet: BottomSheet?
    private let searchLocationDataSource = DemoSearchLocationDataSource()
    private var freeTextSearchSuggestions = [String]()
    private var currentRow: Row?

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .background
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
            charcoalViewController.selectionDelegate = self
            charcoalViewController.textEditingDelegate = self
            charcoalViewController.freeTextFilterDataSource = self
            charcoalViewController.freeTextFilterDelegate = self
            charcoalViewController.searchLocationDataSource = searchLocationDataSource
            if let setup = row.setup {
                charcoalViewController.filterContainer = setup.filterContainer
                charcoalViewController.configure(with: setup.verticals)
                charcoalViewController.updateReloadVerticalsButton(isVisible: setup.showVerticalsReloadButton)
            }
            charcoalViewController.selectionDelegate = self
        } else if let viewController = viewController as? DrawerPresentationViewController {
            let charcoalViewController = viewController.charcoalViewController
            charcoalViewController.selectionDelegate = self
            charcoalViewController.freeTextFilterDataSource = self
            charcoalViewController.freeTextFilterDelegate = self
            charcoalViewController.searchLocationDataSource = searchLocationDataSource
            if let setup = row.setup {
                charcoalViewController.filterContainer = setup.filterContainer
                charcoalViewController.configure(with: setup.verticals)
                charcoalViewController.updateReloadVerticalsButton(isVisible: setup.showVerticalsReloadButton)
            }
            charcoalViewController.selectionDelegate = self

            viewController.transitioningDelegate = viewController.transition
            viewController.modalPresentationStyle = .custom
        }

        if row.usingBottomSheet {
            bottomSheet = BottomSheet(rootViewController: viewController)
            viewController = bottomSheet!
        }

        currentRow = row
        viewController.view.backgroundColor = Theme.mainBackground
        present(viewController, animated: true)
    }
}

extension DemoTableViewController: CharcoalViewControllerSelectionDelegate {
    func charcoalViewController(_ viewController: CharcoalViewController, didSelect vertical: Vertical) {
        guard let vertical = vertical as? DemoVertical, let setup = currentRow?.setup else { return }

        guard !vertical.isExternal else {
            print("🔥 Did select external vertical with title: \(vertical.title)")
            return
        }

        if let subVertical = setup.verticals.first(where: { $0.id == vertical.id }) {
            setup.current = subVertical
            viewController.isLoading = true
            viewController.filterContainer = setup.filterContainer
            viewController.configure(with: setup.verticals)
            viewController.isLoading = false
        }
    }

    func charcoalViewControllerDidPressShowResults(_ viewController: CharcoalViewController) {
        if let bottomSheet = bottomSheet {
            bottomSheet.state = .dismissed
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    func charcoalViewController(_ viewController: CharcoalViewController, didSelectExternalFilterWithKey key: String, value: String?) {
        print("🔥 Did select external filter with key '\(key)' and value '\(value ?? "nil")'")
    }

    func charcoalViewControllerDidSelectReloadVerticals(_ viewController: CharcoalViewController) {
        let verticals: [DemoVertical] = .multiple
        if let setup = currentRow?.setup {
            setup.verticals = verticals
            setup.current = verticals.first
        }
        viewController.updateReloadVerticalsButton(isVisible: false)
        viewController.configure(with: verticals)
    }

    func charcoalViewController(_ viewController: CharcoalViewController, didChangeSelection selection: [URLQueryItem], origin: SelectionChangeOrigin) {}
}

extension DemoTableViewController: CharcoalViewControllerTextEditingDelegate {
    func charcoalViewControllerWillBeginTextEditing(_ viewController: CharcoalViewController) {
        bottomSheet?.state = .expanded
    }

    func charcoalViewControllerWillEndTextEditing(_ viewController: CharcoalViewController) {
        bottomSheet?.state = .compact
    }
}

extension DemoTableViewController: FreeTextFilterDataSource {
    func numberOfSuggestions(in freeTextFilterViewController: FreeTextFilterViewController) -> Int {
        return freeTextSearchSuggestions.count
    }

    func freeTextFilterViewController(_ freeTextFilterViewController: FreeTextFilterViewController,
                                      suggestionAt indexPath: IndexPath) -> String {
        return freeTextSearchSuggestions[indexPath.row]
    }
}

extension DemoTableViewController: FreeTextFilterDelegate {
    func freeTextFilterViewController(_ freeTextFilterViewController: FreeTextFilterViewController,
                                      didChangeText text: String?) {
        if let text = text, !text.isEmpty {
            freeTextSearchSuggestions = (1 ... 10).map { "\(text)\($0)" }
        } else {
            freeTextSearchSuggestions = []
        }

        freeTextFilterViewController.reloadData()
    }
}
