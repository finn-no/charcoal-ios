//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class CCRootFilterViewController: CCViewController {

    // MARK: - Private properties

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SearchQueryCell.self)
        tableView.register(CCInlineFilterCell.self)
        tableView.register(CCRootFilterCell.self)
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var searchQueryViewController: SearchQueryViewController = {
        let searchQueryViewController = SearchQueryViewController()
        searchQueryViewController.delegate = self
        return searchQueryViewController
    }()

    // MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        showBottomButton(true, animated: false)
        bottomButton.buttonTitle = String(format: "show_x_hits_button_title".localized(), filterNode.numberOfResults)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomButton.height, right: 0)
        setup()
    }

    override func viewController(_ viewController: CCViewController, didSelect filterNode: CCFilterNode) {
        super.viewController(viewController, didSelect: filterNode)
        tableView.reloadData()
    }
}

extension CCRootFilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterNode.children.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentFilterNode = filterNode.children[indexPath.row]
        switch currentFilterNode.name {
        case "q":
            let cell = tableView.dequeue(SearchQueryCell.self, for: indexPath)
            cell.searchBar = searchQueryViewController.searchBar
            cell.searchBar?.placeholder = currentFilterNode.title
            return cell

        case "preferences":
            let cell = tableView.dequeue(CCInlineFilterCell.self, for: indexPath)
            cell.delegate = self
            cell.configure(with: currentFilterNode)
            return cell

        default:
            let cell = tableView.dequeue(CCRootFilterCell.self, for: indexPath)
            cell.configure(for: currentFilterNode)
            return cell
        }
    }
}

extension CCRootFilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilterNode = filterNode.children[indexPath.row]
        switch selectedFilterNode.name {
        case "q":
            return
        case "preferences":
            return
        default:
            delegate?.viewController(self, didSelect: selectedFilterNode)
        }
    }
}

extension CCRootFilterViewController: CCInlineFilterViewDelegate {
    func inlineFilterViewDidChangeValue(_ inlineFilterView: CCInlineFilterView) {
        delegate?.viewControllerDidPressBottomButton(self)
    }
}

extension CCRootFilterViewController: SearchViewControllerDelegate {
    func presentSearchViewController(_ searchViewController: SearchQueryViewController) {
        add(searchViewController)
    }

    func searchViewControllerDidCancelSearch(_ searchViewController: SearchQueryViewController) {
        let searchNode = filterNode.children.first { $0.name == "q" }
        searchNode?.value = nil
        searchNode?.isSelected = false
        tableView.reloadData()
    }

    func searchViewController(_ searchViewController: SearchQueryViewController, didSelectQuery query: String) {
        let searchNode = filterNode.children.first { $0.name == "q" }
        searchNode?.value = query
        searchNode?.isSelected = true
        tableView.reloadData()
    }
}

private extension CCRootFilterViewController {
    func setup() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
