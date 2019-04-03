//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol VerticalListViewControllerDelegate: AnyObject {
    func verticalListViewController(_: VerticalListViewController, didSelectVerticalAtIndex index: Int)
}

public class VerticalListViewController: UIViewController {
    static let rowHeight: CGFloat = 48.0

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = true
        registerCells(for: tableView)
        return tableView
    }()

    public weak var delegate: VerticalListViewControllerDelegate?
    public let popoverTransitionDelegate = CustomPopoverTransitioningDelegate()

    private let verticals: [Vertical]

    // MARK: - Init

    public required init(verticals: [Vertical]) {
        self.verticals = verticals
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = popoverTransitionDelegate
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - Setup

    private func setup(withSourceView source: UIView, inContainerView view: UIView) {
        let sourceViewBottom = view.convert(CGPoint(x: 0, y: source.bounds.maxY), from: source).y
        let maxHeightForPopover = view.bounds.height - sourceViewBottom - 20
        let numberOfRowsFitting = maxHeightForPopover / VerticalListViewController.rowHeight

        let popoverHeight: CGFloat

        if numberOfRowsFitting < CGFloat(verticals.count) {
            popoverHeight = (floor(numberOfRowsFitting) - 0.5) * VerticalListViewController.rowHeight
        } else {
            popoverHeight = CGFloat(verticals.count) * VerticalListViewController.rowHeight
        }

        preferredContentSize = CGSize(width: view.frame.size.width, height: popoverHeight)
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

// MARK: - UITableViewDataSource

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

// MARK: - UITableViewDelegate

extension VerticalListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.verticalListViewController(self, didSelectVerticalAtIndex: indexPath.item)
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return type(of: self).rowHeight
    }
}
