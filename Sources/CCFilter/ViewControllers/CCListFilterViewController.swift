//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

final class CCListFilterViewController: CCViewController {
    private enum Section: Int {
        case all, children
    }

    // MARK: - Private properties

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CCListFilterCell.self)
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private var showSelectAllCell: Bool {
        return filterNode.value != nil
    }

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        bottomButton.buttonTitle = "apply_button_title".localized()
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

    // MARK: - Setup

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

// MARK: - UITableViewDataSource

extension CCListFilterViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }

        switch section {
        case .all:
            return showSelectAllCell ? 1 : 0
        case .children:
            return filterNode.children.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { fatalError("Apple screwed up!") }

        let cell = tableView.dequeue(CCListFilterCell.self, for: indexPath)

        switch section {
        case .all:
            let isSelected = selectionStore.isSelected(filterNode)
            cell.configure(for: .selectAll(from: filterNode, isSelected: isSelected))
        case .children:
            if let node = filterNode.child(at: indexPath.row) {
                if node.name == CCMapFilterNode.filterKey {
                    cell.configure(for: .map(from: node))
                } else {
                    let isSelected = selectionStore.isSelected(node)
                    let hasSelectedChildren = selectionStore.hasSelectedChildren(node: node)
                    cell.configure(for: .regular(from: node, isSelected: isSelected, hasSelectedChildren: hasSelectedChildren))
                }
            }
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension CCListFilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }

        switch section {
        case .all:
            for childNode in filterNode.children {
                selectionStore.removeValue(for: childNode)
            }

            selectionStore.toggleValue(for: filterNode)
            tableView.reloadData()
            showBottomButton(true, animated: true)
        case .children:
            guard let childNode = filterNode.child(at: indexPath.row) else {
                return
            }

            if childNode.isLeafNode {
                selectionStore.removeValue(for: filterNode)
                selectionStore.toggleValue(for: childNode)
                showBottomButton(true, animated: true)
            }

            let selectAllIndexPath = showSelectAllCell ? IndexPath(item: 0, section: Section.all.rawValue) : nil
            let indexPaths = [indexPath, selectAllIndexPath].compactMap({ $0 })
            tableView.reloadRows(at: indexPaths, with: .fade)

            delegate?.viewController(self, didSelect: childNode)
        }
    }
}
