//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol ListItem {
    var title: String { get }
}

protocol SelectionListItemCellConfigurator: AnyObject {
    func configure(_ cell: SelectionListItemCell, listItem: ListItem)
}

protocol ListViewControllerDelegate: AnyObject {
    func listViewController(_: ListViewController, didSelectListItem listItem: ListItem, at indexPath: IndexPath, in tableView: UITableView)
}

public class ListViewController: UIViewController {
    private static var rowHeight: CGFloat = 48.0

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        registerCells(for: tableView)
        return tableView
    }()

    public let listItems: [ListItem]
    weak var selectionListItemCellConfigurator: SelectionListItemCellConfigurator?
    weak var listViewControllerDelegate: ListViewControllerDelegate?

    public init(title: String, items: [ListItem]) {
        listItems = items
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    func registerCells(for tableView: UITableView) {
        tableView.register(SelectionListItemCell.self)
    }

    func updateCellIfVisible(at indexPath: IndexPath) {
        guard tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false else {
            return
        }
        if let cell = tableView.cellForRow(at: indexPath) as? SelectionListItemCell, let listItem = listItems[safe: indexPath.row] {
            selectionListItemCellConfigurator?.configure(cell, listItem: listItem)
        }
    }
}

extension ListViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItems.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(SelectionListItemCell.self, for: indexPath)
        if let listItem = listItems[safe: indexPath.row] {
            selectionListItemCellConfigurator?.configure(cell, listItem: listItem)
        }
        return cell
    }
}

extension ListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let listItem = listItems[safe: indexPath.row] else {
            return
        }
        listViewControllerDelegate?.listViewController(self, didSelectListItem: listItem, at: indexPath, in: tableView)
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ListViewController.rowHeight
    }
}

private extension ListViewController {
    func setup() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

extension ListViewController: ScrollableContainerViewController {
    public var mainScrollableView: UIScrollView {
        return tableView
    }
}
