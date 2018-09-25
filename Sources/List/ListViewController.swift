//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol ListItem {
    var title: String { get }
    var detail: String? { get }
    var showsDisclosureIndicator: Bool { get }
    var value: String { get }
}

public protocol ListItemSelectionStateProvider {
    func isListItemSelected(_ listItem: ListItem) -> Bool
}

public class ListViewController: UIViewController {
    private static var rowHeight: CGFloat = 48.0

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(SelectionListItemCell.self)

        return tableView
    }()

    public let listItems: [ListItem]
    public let listItemSelectionStateProvider: ListItemSelectionStateProvider?

    public init(title: String, items: [ListItem], allowsMultipleSelection: Bool = false, listItemSelectionStateProvider: ListItemSelectionStateProvider? = nil) {
        listItems = items
        self.listItemSelectionStateProvider = listItemSelectionStateProvider
        super.init(nibName: nil, bundle: nil)
        self.title = title
        tableView.allowsMultipleSelection = allowsMultipleSelection
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        listItems = []
        listItemSelectionStateProvider = nil
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init?(coder aDecoder: NSCoder) {
        listItems = []
        listItemSelectionStateProvider = nil
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

        let cell = tableView.dequeue(SelectionListItemCell.self, for: indexPath)
        cell.configure(for: listItem)
        cell.selectionIndicatorType = tableView.allowsMultipleSelection ? .checkbox : .radioButton
        cell.setSelectionMarker(visible: isItemSelected(listItem))

        return cell
    }
}

extension ListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    func isItemSelected(_ listItem: ListItem) -> Bool {
        return listItemSelectionStateProvider?.isListItemSelected(listItem) ?? false
    }

    final func indexesForSelectedListItems() -> [Int]? {
        return listItems.enumerated().compactMap({ isItemSelected($0.element) ? $0.offset : nil })
    }

    final func indexForSelectedListItem() -> Int? {
        return indexesForSelectedListItems()?.first
    }
}
