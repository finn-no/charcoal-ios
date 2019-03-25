//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

final class ListFilterViewController: FilterViewController {
    private enum Section: Int {
        case all, subfilters
    }

    // MARK: - Private properties

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ListFilterCell.self)
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 48
        return tableView
    }()

    private let filter: Filter
    private let viewModels = [Section: [ListFilterCellViewModel]]()

    private var canSelectAll: Bool {
        return filter.value != nil
    }

    // MARK: - Init

    init(filter: Filter, selectionStore: FilterSelectionStore) {
        self.filter = filter
        super.init(title: filter.title, selectionStore: selectionStore)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        bottomButton.buttonTitle = "applyButton".localized()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Data

    private func reloadViewModels() {
    }

    // MARK: - Setup

    private func setup() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomButton.topAnchor),
        ])
    }
}

// MARK: - UITableViewDataSource

extension ListFilterViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }

        switch section {
        case .all:
            return canSelectAll ? 1 : 0
        case .subfilters:
            return filter.subfilters.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { fatalError("Apple screwed up!") }

        let cell = tableView.dequeue(ListFilterCell.self, for: indexPath)
        let viewModel: ListFilterCellViewModel
        let isAllSelected = canSelectAll && selectionStore.isSelected(filter)
        let isEnabled = !isAllSelected || section == .all

        switch section {
        case .all:
            viewModel = .selectAll(from: filter, isSelected: isAllSelected, isEnabled: isEnabled)
        case .subfilters:
            let subfilter = filter.subfilters[indexPath.row]

            switch subfilter.kind {
            case .external:
                viewModel = .external(from: subfilter, isEnabled: isEnabled)
            default:
                let hasSelectedSubfilters = selectionStore.hasSelectedSubfilters(for: subfilter)
                let isSelected = selectionStore.isSelected(subfilter) || hasSelectedSubfilters || isAllSelected
                viewModel = .regular(from: subfilter, isSelected: isSelected, isEnabled: isEnabled)
            }
        }

        cell.configure(with: viewModel)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ListFilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }

        tableView.deselectRow(at: indexPath, animated: false)

        switch section {
        case .all:
            let isSelected = selectionStore.toggleValue(for: filter)

            animateSelectionForRow(at: indexPath, isSelected: isSelected)
            tableView.reloadSections(IndexSet(integer: Section.subfilters.rawValue), with: .fade)
            showBottomButton(true, animated: true)
        case .subfilters:
            let subfilter = filter.subfilters[indexPath.row]

            switch subfilter.kind {
            case _ where !subfilter.subfilters.isEmpty, .external:
                break
            default:
                let isSelected = selectionStore.toggleValue(for: subfilter)

                animateSelectionForRow(at: indexPath, isSelected: isSelected)
                showBottomButton(true, animated: true)
                tableView.scrollToRow(at: indexPath, at: .none, animated: true)
            }

            delegate?.filterViewController(self, didSelectFilter: subfilter)
        }
    }

    private func animateSelectionForRow(at indexPath: IndexPath, isSelected: Bool) {
        if let cell = tableView.cellForRow(at: indexPath) as? ListFilterCell {
            cell.animateSelection(isSelected: isSelected)
        }
    }
}
