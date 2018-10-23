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
        selectionListItemCellConfigurator = self
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
}

extension VerticalListViewController: ListViewControllerDelegate {
    func listViewController(_: ListViewController, didSelectListItem listItem: ListItem, at indexPath: IndexPath, in tableView: UITableView) {
        if let vertical = verticals[safe: indexPath.item] {
            delegate?.verticalListViewController(self, didSelectVertical: vertical, at: indexPath.item)
        }
        updateCell(at: indexPath)
    }
}

extension VerticalListViewController: SelectionListItemCellConfigurator {
    func configure(_ cell: SelectionListItemCell, listItem: ListItem) {
        cell.selectionIndicatorType = .radioButton
        cell.configure(for: listItem)
        if let vertical = listItem as? Vertical {
            cell.setSelectionMarker(visible: vertical.isCurrent)
        }
    }
}
