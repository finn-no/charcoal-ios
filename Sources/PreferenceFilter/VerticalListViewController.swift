//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class VerticalListViewController: ListViewController {
    public var controller: UIViewController {
        return self
    }

    public var filterSelectionDelegate: FilterContainerViewControllerDelegate?

    let verticals: [Vertical]

    public required init(verticals: [Vertical]) {
        self.verticals = verticals
        super.init(title: "", items: [])
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
        //toggleSelection(for: listItem)
        // updateCell(at: indexPath)
    }
}

extension VerticalListViewController: SelectionListItemCellConfigurator {
    func configure(_ cell: SelectionListItemCell, listItem: ListItem) {
        cell.configure(for: listItem)
        // cell.selectionIndicatorType = filterInfo.isMultiSelect ? .checkbox : .radioButton
        // cell.setSelectionMarker(visible: isListItemSelected(listItem))
    }
}
