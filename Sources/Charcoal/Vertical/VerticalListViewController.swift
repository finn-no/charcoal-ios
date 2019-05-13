//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

protocol VerticalListViewControllerDelegate: AnyObject {
    func verticalListViewController(_: VerticalListViewController, didSelectVerticalAtIndex index: Int)
}

final class VerticalListViewController: UIViewController {
    private static let rowHeight: CGFloat = 48.0

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = true
        tableView.removeLastCellSeparator()
        registerCells(for: tableView)
        return tableView
    }()

    private lazy var shadowView = ShadowView()

    weak var delegate: VerticalListViewControllerDelegate?

    var verticals: [Vertical] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
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
        view.addSubview(shadowView)

        NSLayoutConstraint.activate([
            shadowView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            shadowView.bottomAnchor.constraint(equalTo: view.topAnchor),
            shadowView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            shadowView.heightAnchor.constraint(equalToConstant: 44),

            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func registerCells(for tableView: UITableView) {
        tableView.register(VerticalCell.self)
    }

    private func configure(_ cell: VerticalCell, vertical: Vertical) {
        cell.configure(for: vertical)
    }
}

// MARK: - UITableViewDataSource

extension VerticalListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return verticals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(VerticalCell.self, for: indexPath)

        if let vertical = verticals[safe: indexPath.row] {
            configure(cell, vertical: vertical)
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension VerticalListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.verticalListViewController(self, didSelectVerticalAtIndex: indexPath.item)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return type(of: self).rowHeight
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        shadowView.update(with: scrollView)
    }
}
