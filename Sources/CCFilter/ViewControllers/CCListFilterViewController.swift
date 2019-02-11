//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

extension CCListFilterViewController {
    enum Section: Int {
        case all, children
    }
}

class CCListFilterViewController: CCViewController {

    // MARK: - Private properties

    private var selectAllNode: CCFilterNode?
    private let selectAllIndexPath = IndexPath(item: 0, section: Section.all.rawValue)

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CCListFilterCell.self)
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        bottomButton.buttonTitle = "Bruk"

        if filterNode.value != nil {
            selectAllNode = CCFilterNode(title: "All", name: "", isSelected: filterNode.isSelected, numberOfResults: filterNode.numberOfResults)
        }

        setup()
    }

    override func showBottomButton(_ show: Bool, animated: Bool) {
        super.showBottomButton(show, animated: animated)
        let bottomInset = show ? bottomButton.height : 0
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
    }

    override func viewController(_ viewController: CCViewController, didSelect filterNode: CCFilterNode) {
        super.viewController(viewController, didSelect: filterNode)
        showBottomButton(true, animated: false)
        tableView.reloadData()
    }
}

extension CCListFilterViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .all: return selectAllNode != nil ? 1 : 0
        case .children: return filterNode.children.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { fatalError("Apple screwed up!") }
        let cell = tableView.dequeue(CCListFilterCell.self, for: indexPath)
        switch section {
        case .all:
            guard let selectAllNode = selectAllNode else { fatalError("I screwed up!") }
            cell.configure(for: selectAllNode)
        case .children:
            if let childNode = filterNode.child(at: indexPath.row) {
                cell.configure(for: childNode)
            }
        }
        return cell
    }
}

extension CCListFilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }

        let selectedFilterNode: CCFilterNode
        var indexPathsToReload: [IndexPath] = [indexPath]

        switch section {
        case .all:
            guard let selectAllNode = selectAllNode else { return }
            filterNode.isSelected = !filterNode.isSelected
            selectAllNode.isSelected = !selectAllNode.isSelected
            selectedFilterNode = selectAllNode

        case .children:
            guard let childNode = filterNode.child(at: indexPath.row) else { return }
            selectedFilterNode = childNode
            guard selectedFilterNode.isLeafNode else { break }
            selectedFilterNode.isSelected = !selectedFilterNode.isSelected
            selectAllNode?.isSelected = filterNode.isSelected

            if selectAllNode != nil {
                indexPathsToReload.append(selectAllIndexPath)
            }

            showBottomButton(true, animated: true)
        }

        tableView.reloadRows(at: indexPathsToReload, with: .fade)
        delegate?.viewController(self, didSelect: selectedFilterNode)
    }
}

private extension CCListFilterViewController {
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
