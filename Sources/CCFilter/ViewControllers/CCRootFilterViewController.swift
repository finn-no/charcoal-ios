//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol CCRootFilterViewControllerDelegate: class {
    func rootFilterViewController(_ viewController: CCRootFilterViewController, didSelectVerticalAt index: Int)
}

class CCRootFilterViewController: CCViewController {

    // MARK: - Public properties

    var verticals: [Vertical]?

    weak var rootDelegate: (CCRootFilterViewControllerDelegate & CCViewControllerDelegate)? {
        didSet { delegate = rootDelegate }
    }

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

    private var searchNode: CCFilterNode? {
        return filterNode.children.first { $0.name == "q" }
    }

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

    func set(filterNode: CCFilterNode, verticals: [Vertical]?) {
        self.filterNode = filterNode
        self.verticals = verticals
        navigationItem.title = filterNode.title
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
            let segmentTitles = currentFilterNode.children.map({ $0.children.map({ $0.title }) })
            let vertical = verticals?.first(where: { $0.isCurrent })
            cell.configure(with: segmentTitles, vertical: vertical?.title)
            return cell

        default:
            let cell = tableView.dequeue(CCRootFilterCell.self, for: indexPath)
            cell.delegate = self

            let titles = selectionStore.titles(for: currentFilterNode)
            cell.configure(withTitle: currentFilterNode.title, selectionTitles: titles)
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

extension CCRootFilterViewController: CCRootFilterCellDelegate {
    func rootFilterCell(_ cell: CCRootFilterCell, didRemoveItemAt index: Int) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        let currentFilterNode = filterNode.children[indexPath.row]
        let selectedChildren = selectionStore.selectedChildren(for: currentFilterNode)

        selectionStore.removeValues(for: selectedChildren[index])
    }
}

extension CCRootFilterViewController: CCInlineFilterViewDelegate {
    func inlineFilterView(_ inlineFilterView: CCInlineFilterView, didChangeSegment segment: Segment, at index: Int) {
        guard let childNode = filterNode.child(at: index) else { return }

        selectionStore.removeValues(for: childNode)

        for index in segment.selectedItems {
            if let node = childNode.child(at: index) {
                selectionStore.setValue(from: node)
            }
        }
    }

    func inlineFilterView(_ inlineFilterview: CCInlineFilterView, didTapExpandableSegment segment: Segment) {
        guard let verticals = verticals else { return }
        let verticalViewController = VerticalListViewController(verticals: verticals)
        verticalViewController.popoverTransitionDelegate.willDismissPopoverHandler = { _ in segment.selectedItems = [] }
        verticalViewController.popoverTransitionDelegate.sourceView = segment
        verticalViewController.delegate = self
        present(verticalViewController, animated: true, completion: nil)
    }
}

extension CCRootFilterViewController: VerticalListViewControllerDelegate {
    func verticalListViewController(_ verticalViewController: VerticalListViewController, didSelectVerticalAtIndex index: Int) {
        verticalViewController.dismiss(animated: false)
        rootDelegate?.rootFilterViewController(self, didSelectVerticalAt: index)
    }
}

extension CCRootFilterViewController: SearchViewControllerDelegate {
    func presentSearchViewController(_ searchViewController: SearchQueryViewController) {
        add(searchViewController)
    }

    func searchViewControllerDidCancelSearch(_ searchViewController: SearchQueryViewController) {
        guard let searchNode = searchNode else {
            return
        }

        selectionStore.removeValues(for: searchNode)
        tableView.reloadData()
    }

    func searchViewController(_ searchViewController: SearchQueryViewController, didSelectQuery query: String) {
        guard let searchNode = searchNode else {
            return
        }

        selectionStore.setValue(query, for: searchNode)
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
