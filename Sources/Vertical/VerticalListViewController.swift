//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol VerticalListViewControllerDelegate: AnyObject {
    func verticalListViewController(_: VerticalListViewController, didSelectVertical vertical: Vertical, at index: Int)
}

public class VerticalListViewController: UIViewController {
    private static var rowHeight: CGFloat = 48.0

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        registerCells(for: tableView)
        return tableView
    }()

    public weak var delegate: VerticalListViewControllerDelegate?

    private let verticals: [Vertical]

    public required init(verticals: [Vertical]) {
        self.verticals = verticals
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func registerCells(for tableView: UITableView) {
        tableView.register(VerticalSelectionCell.self)
    }

    private func configure(_ cell: VerticalSelectionCell, vertical: Vertical) {
        cell.configure(for: vertical)
    }
}

extension VerticalListViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return verticals.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(VerticalSelectionCell.self, for: indexPath)
        if let vertical = verticals[safe: indexPath.row] {
            configure(cell, vertical: vertical)
        }
        return cell
    }
}

extension VerticalListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vertical = verticals[safe: indexPath.item] {
            delegate?.verticalListViewController(self, didSelectVertical: vertical, at: indexPath.item)
        }
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return type(of: self).rowHeight
    }
}

extension VerticalListViewController: ScrollableContainerViewController {
    public var mainScrollableView: UIScrollView {
        return tableView
    }
}
