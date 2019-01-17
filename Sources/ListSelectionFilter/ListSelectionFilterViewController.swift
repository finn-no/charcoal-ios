//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

public final class ListSelectionFilterViewController: FilterViewController {
    private let filterInfo: ListSelectionFilterInfoType

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

    private let listItems: [FilterValueType]

    public init(filterInfo: ListSelectionFilterInfoType, dataSource: FilterDataSource, selectionDataSource: FilterSelectionDataSource, navigator: FilterNavigator?) {
        self.filterInfo = filterInfo
        listItems = filterInfo.values
        super.init(dataSource: dataSource, selectionDataSource: selectionDataSource, navigator: navigator)
        title = filterInfo.title
    }

    required init(coder aDecoder: NSCoder) {
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
            tableView.bottomAnchor.constraint(equalTo: applySelectionButton.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func registerCells(for tableView: UITableView) {
        tableView.register(SelectionListItemCell.self)
    }

    private func updateCellIfVisible(at indexPath: IndexPath) {
        guard tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false else {
            return
        }
        if let cell = tableView.cellForRow(at: indexPath) as? SelectionListItemCell, let listItem = listItems[safe: indexPath.row] {
            configure(cell, listItem: listItem)
        }
    }

    private func toggleSelection(for item: FilterValueType) {
        let wasItemPreviouslySelected = isListItemSelected(item)
        if filterInfo.isMultiSelect {
            if wasItemPreviouslySelected {
                selectionDataSource.clearValue(item.value, for: filterInfo)
            } else {
                selectionDataSource.addValue(item.value, for: filterInfo)
            }
        } else {
            selectionDataSource.clearAll(for: filterInfo)
            if !wasItemPreviouslySelected {
                selectionDataSource.setValue([item.value], for: filterInfo)
            }
        }
    }

    private func isListItemSelected(_ item: FilterValueType) -> Bool {
        guard let currentSelection = selectionDataSource.value(for: filterInfo) else {
            return false
        }
        return currentSelection.contains(item.value)
    }

    private func configure(_ cell: SelectionListItemCell, listItem: FilterValueType) {
        cell.configure(title: listItem.title, hits: dataSource.numberOfHits(for: listItem), showDisclosureIndicator: false)
        cell.selectionIndicatorType = filterInfo.isMultiSelect ? .checkbox : .radioButton
        cell.setSelectionMarker(visible: isListItemSelected(listItem))
    }
}

extension ListSelectionFilterViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItems.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(SelectionListItemCell.self, for: indexPath)
        if let listItem = listItems[safe: indexPath.row] {
            configure(cell, listItem: listItem)
        }
        return cell
    }
}

extension ListSelectionFilterViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let listItem = listItems[safe: indexPath.row] else {
            return
        }
        toggleSelection(for: listItem)
        updateCellIfVisible(at: indexPath)
        showApplyButton(selectionDataSource.value(for: filterInfo) != nil, animated: true)
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return type(of: self).rowHeight
    }
}
