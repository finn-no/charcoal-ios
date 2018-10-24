//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol VerticalListViewControllerDelegate: AnyObject {
    func verticalListViewController(_: VerticalListViewController, didSelectVertical vertical: Vertical, at index: Int)
}

public class VerticalListViewController: ListViewController {
    public var delegate: VerticalListViewControllerDelegate?

    let verticals: [Vertical]

    public required init(verticals: [Vertical]) {
        self.verticals = verticals
        super.init(title: "", items: verticals)
        listViewControllerDelegate = self
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func isListItemSelected(_ listItem: ListItem) -> Bool {
        guard let item = listItem as? PreferenceValueType else {
            return false
        }
        return isListSelectionFilterValueSelected(item)
    }

    private func isListSelectionFilterValueSelected(_ item: ListItem) -> Bool {
        return false
    }

    override func registerCells(for tableView: UITableView) {
        tableView.register(VerticalSelectionCell.self)
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(VerticalSelectionCell.self, for: indexPath)
        if let listItem = listItems[safe: indexPath.row] {
            configure(cell, listItem: listItem)
        }
        return cell
    }
}

extension VerticalListViewController: ListViewControllerDelegate {
    func listViewController(_: ListViewController, didSelectListItem listItem: ListItem, at indexPath: IndexPath, in tableView: UITableView) {
        if let vertical = verticals[safe: indexPath.item] {
            delegate?.verticalListViewController(self, didSelectVertical: vertical, at: indexPath.item)
        }
        updateCell(at: indexPath)
    }
}

extension VerticalListViewController {
    func configure(_ cell: VerticalSelectionCell, listItem: ListItem) {
        guard let vertical = listItem as? Vertical else {
            return
        }
        cell.configure(for: vertical)
    }
}
