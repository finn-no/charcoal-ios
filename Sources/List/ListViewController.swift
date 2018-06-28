//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol ListViewControllerDelegate: AnyObject {
    func listViewController(_ listViewController: ListViewController, didSelectListItem listItem: ListItem, atIndex index: Int)
}

public protocol ListItem {
    var title: String? { get }
    var detail: String? { get }
    var showsDisclosureIndicator: Bool { get }
}

public class ListViewController: UIViewController {
    private static var rowHeight: CGFloat = 48.0

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = true
        tableView.register(SelectionListItemCell.self)

        return tableView
    }()

    public weak var delegate: ListViewControllerDelegate?
    public let listItems: [ListItem]

    public init(title: String, items: [ListItem], allowsMultipleSelection: Bool = false) {
        listItems = items
        super.init(nibName: nil, bundle: nil)
        self.title = title
        tableView.allowsMultipleSelection = allowsMultipleSelection
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        listItems = []
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init?(coder aDecoder: NSCoder) {
        listItems = []
        super.init(coder: aDecoder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
}

extension ListViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItems.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listItem = listItems[indexPath.row]

        let cell = tableView.dequeueReusableCell(for: indexPath) as SelectionListItemCell
        cell.configure(for: listItem)
        cell.selectionIndicatorType = tableView.allowsMultipleSelection ? .checkbox : .radioButton

        return cell
    }
}

extension ListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let listItem = listItems[indexPath.row]
        delegate?.listViewController(self, didSelectListItem: listItem, atIndex: indexPath.row)
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

public extension ListViewController {
    final func indexesForSelectedListItems() -> [Int]? {
        return tableView.indexPathsForSelectedRows?.map({ $0.row })
    }

    final func indexForSelectedListItem() -> Int? {
        return tableView.indexPathForSelectedRow?.row
    }
}
