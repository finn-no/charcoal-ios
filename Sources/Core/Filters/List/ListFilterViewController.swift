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
    private var lastSelectedIndexPath: IndexPath?

    private var showSelectAllCell: Bool {
        return filter.value != nil
    }

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
        bottomButton.buttonTitle = "apply_button_title".localized()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func showBottomButton(_ show: Bool, animated: Bool) {
        super.showBottomButton(show, animated: animated)
        let bottomInset = show ? bottomButton.height : 0
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
    }

    // MARK: - Setup

    func setup() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
            return showSelectAllCell ? 1 : 0
        case .subfilters:
            return filter.subfilters.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { fatalError("Apple screwed up!") }

        let cell = tableView.dequeue(ListFilterCell.self, for: indexPath)
        let viewModel: ListFilterCellViewModel

        switch section {
        case .all:
            let isSelected = selectionStore.isSelected(filter)
            viewModel = .selectAll(from: filter, isSelected: isSelected)
        case .subfilters:
            let subfilter = filter.subfilters[indexPath.row]

            switch subfilter.kind {
            case .external:
                viewModel = .external(from: subfilter)
            default:
                let isSelected = selectionStore.isSelected(subfilter)
                let hasSelectedSubfilters = selectionStore.hasSelectedSubfilters(for: subfilter)
                viewModel = .regular(from: subfilter, isSelected: isSelected, hasSelectedSubfilters: hasSelectedSubfilters)
            }
        }

        cell.configure(with: viewModel, animated: indexPath == lastSelectedIndexPath)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ListFilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }

        lastSelectedIndexPath = indexPath

        switch section {
        case .all:
            for subfilter in filter.subfilters {
                selectionStore.removeValues(for: subfilter)
            }

            selectionStore.toggleValue(for: filter)
            tableView.reloadData()
            showBottomButton(true, animated: true)
        case .subfilters:
            guard let subfilter = filter.subfilter(at: indexPath.row) else {
                return
            }

            if subfilter.subfilters.isEmpty {
                if selectionStore.isSelected(filter) {
                    selectionStore.removeValues(for: filter)
                }

                selectionStore.toggleValue(for: subfilter)

                let selectAllIndexPath = showSelectAllCell ? IndexPath(item: 0, section: Section.all.rawValue) : nil
                let indexPaths = [indexPath, selectAllIndexPath].compactMap({ $0 })
                tableView.reloadRows(at: indexPaths, with: .none)

                showBottomButton(true, animated: true)
            }

            lastSelectedIndexPath = nil
            delegate?.filterViewController(self, didSelectFilter: subfilter)
        }
    }
}
