//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import Warp

public final class ListFilterViewController: FilterViewController {
    private enum Section: Int {
        case all, subfilters
    }

    // MARK: - Private properties

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ListFilterCell.self)
        tableView.removeLastCellSeparator()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 48
        tableView.backgroundColor = Theme.mainBackground
        return tableView
    }()

    private lazy var searchBar: UISearchBar = {
        let searchBar = FreeTextFilterSearchBar(frame: .zero)
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.backgroundColor = Theme.mainBackground
        searchBar.placeholder = "filterAsYouType.placeholder".localized()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private let filter: Filter
    private var scopedSubfilters: [Filter]
    private let notificationCenter: NotificationCenter
    private let searchbarSubfilterThreshold: Int

    private var canSelectAll: Bool {
        return filter.value != nil
    }

    private lazy var tableViewBottomAnchorConstraint: NSLayoutConstraint = {
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    }()

    // MARK: - Init

    public init(filter: Filter, selectionStore: FilterSelectionStore, searchbarSubfilterThreshold: Int = 20, notificationCenter: NotificationCenter = .default) {
        self.filter = filter
        scopedSubfilters = filter.subfilters
        self.searchbarSubfilterThreshold = searchbarSubfilterThreshold
        self.notificationCenter = notificationCenter
        super.init(title: filter.title, selectionStore: selectionStore)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    public override func viewDidLoad() {
        super.viewDidLoad()
        bottomButton.buttonTitle = "applyButton".localized()
        setup()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        view.layoutIfNeeded()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notificationCenter.removeObserver(self)
    }

    public override func showBottomButton(_ show: Bool, animated: Bool) {
        super.showBottomButton(show, animated: animated)
        if show {
            tableViewBottomAnchorConstraint.constant = -bottomButton.frame.height
            view.layoutIfNeeded()
        }
        bottomButton.update(with: tableView)
    }

    // MARK: - Setup

    private func setup() {
        view.insertSubview(tableView, belowSubview: bottomButton)

        let sharedTableViewConstraints = [
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableViewBottomAnchorConstraint,
        ]

        if filter.subfilters.count >= searchbarSubfilterThreshold {
            view.addSubview(searchBar)

            topShadowViewBottomAnchor.isActive = false

            let searchBarConstraints = [
                searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Warp.Spacing.spacing100),
                searchBar.topAnchor.constraint(equalTo: view.topAnchor),
                searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Warp.Spacing.spacing100),

                topShadowView.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor),
                tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            ]

            NSLayoutConstraint.activate(sharedTableViewConstraints + searchBarConstraints)
        } else {
            NSLayoutConstraint.activate(sharedTableViewConstraints + [tableView.topAnchor.constraint(equalTo: view.topAnchor)])
        }
    }

    // MARK: - Overrides

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        searchBar.endEditing(true)
    }

    // MARK: - Actions

    @objc private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        var keyboardHeight = view.convert(keyboardValue.cgRectValue, from: view.window).height
        keyboardHeight -= view.window?.safeAreaInsets.bottom ?? 0

        if notification.name == UIResponder.keyboardWillHideNotification {
            tableView.contentInset = .zero
        } else {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        }

        tableView.scrollIndicatorInsets = tableView.contentInset
    }
}

// MARK: - UITableViewDataSource

extension ListFilterViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }

        switch section {
        case .all:
            return canSelectAll ? 1 : 0
        case .subfilters:
            return scopedSubfilters.count
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { fatalError("Apple screwed up!") }

        let cell = tableView.dequeue(ListFilterCell.self, for: indexPath)
        let viewModel: ListFilterCellViewModel
        let isAllSelected = canSelectAll && selectionStore.isSelected(filter)
        let isEnabled = !isAllSelected || section == .all

        switch section {
        case .all:
            viewModel = .selectAll(from: filter, isSelected: isAllSelected)
        case .subfilters:
            let subfilter = scopedSubfilters[indexPath.row]

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
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }

        tableView.deselectRow(at: indexPath, animated: false)

        switch section {
        case .all:
            let isSelected = selectionStore.toggleValue(for: filter)

            animateSelectionForRow(at: indexPath, isSelected: isSelected)
            tableView.reloadSections(IndexSet(integer: Section.subfilters.rawValue), with: .fade)
            showBottomButton(true, animated: true)
        case .subfilters:
            let subfilter = scopedSubfilters[indexPath.row]

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
            cell.configure(isSelected: isSelected)
        }
    }
}

// MARK: - UISearchBarDelegate

extension ListFilterViewController: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            scopedSubfilters = filter.subfilters
        } else {
            let searchTextLowercased = searchText.lowercased()
            // Find subfilters matching the query and make those who are prefixed with the query appear at the top.
            scopedSubfilters = filter.subfilters
                .filter { $0.title.lowercased().contains(searchTextLowercased) }
                .sorted {
                    let first = $0.title.lowercased().hasPrefix(searchTextLowercased) ? 0 : 1
                    let second = $1.title.lowercased().hasPrefix(searchTextLowercased) ? 0 : 1
                    return first < second
                }
        }

        tableView.reloadData()
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}
