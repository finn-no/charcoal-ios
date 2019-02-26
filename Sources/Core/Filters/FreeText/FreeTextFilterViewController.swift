//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import UIKit

public protocol FreeTextFilterDataSource: class {
    func numberOfSuggestions(in freeTextFilterViewController: FreeTextFilterViewController) -> Int
    func freeTextFilterViewController(_ freeTextFilterViewController: FreeTextFilterViewController, suggestionForCellAt indexPath: IndexPath) -> String
}

public protocol FreeTextFilterDelegate: class {
    func freeTextFilterViewController(_ freeTextFilterViewController: FreeTextFilterViewController, didChangeText text: String?)
}

// Internal protocol to delegate back to root filter view controller
protocol FreeTextFilterViewControllerDelegate: class {
    func freeTextFilterViewControllerWillBeginEditing(_ viewController: FreeTextFilterViewController)
    func freeTextFilterViewControllerWillEndEditing(_ viewController: FreeTextFilterViewController)
    func freeTextFilterViewController(_ viewController: FreeTextFilterViewController, didSelectValue value: String?, forFilter filter: Filter)
}

public class FreeTextFilterViewController: UIViewController {

    // MARK: - Public Properties

    weak var filterDelegate: FreeTextFilterDelegate?
    weak var filterDataSource: FreeTextFilterDataSource?

    weak var delegate: FreeTextFilterViewControllerDelegate?

    var filter: Filter?

    // MARK: - Private Properties

    private var currentQuery: String?
    private var didClearText = false

    private(set) lazy var searchBar: UISearchBar = {
        let searchBar = SearchQuerySearchBar(frame: .zero)
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.backgroundColor = .milk
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(IconTitleTableViewCell.self)
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    func setup(with filter: Filter) {
        self.filter = filter
        searchBar.placeholder = filter.title
    }

    // MARK: - Public methods

    public func reloadData() {
        tableView.reloadData()
    }
}

// MARK: - TableView DataSource

extension FreeTextFilterViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterDataSource?.numberOfSuggestions(in: self) ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(IconTitleTableViewCell.self, for: indexPath)
        let title = filterDataSource?.freeTextFilterViewController(self, suggestionForCellAt: indexPath)
        cell.titleLabel.font = .regularBody
        cell.configure(with: FreeTextSuggestionCellViewModel(title: title ?? ""))
        cell.separatorInset = .leadingInset(48)
        return cell
    }
}

// MARK: - TableView Delegate

extension FreeTextFilterViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let filter = filter, let value = filterDataSource?.freeTextFilterViewController(self, suggestionForCellAt: indexPath) else { return }
        searchBar.text = value
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.freeTextFilterViewController(self, didSelectValue: value, forFilter: filter)
        currentQuery = value
        returnToSuperView()
    }
}

// MARK: - SearchBar Delegate

extension FreeTextFilterViewController: UISearchBarDelegate {
    public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // User clicked the x-button and cleared the text -> should not begin editing
        guard !didClearText else {
            didClearText = false
            return false
        }
        // Present if needed
        if searchBar.superview != view {
            setup()
            tableView.reloadData()
            delegate?.freeTextFilterViewControllerWillBeginEditing(self)
        }

        return true
    }

    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: false)
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let filter = filter, let text = searchBar.text else { return }
        delegate?.freeTextFilterViewController(self, didSelectValue: text, forFilter: filter)
        currentQuery = searchBar.text
        returnToSuperView()
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard let filter = filter else { return }

        if let currentQuery = currentQuery {
            // return to previous search
            searchBar.text = currentQuery
            filterDelegate?.freeTextFilterViewController(self, didChangeText: currentQuery)
        } else {
            delegate?.freeTextFilterViewController(self, didSelectValue: nil, forFilter: filter)
            searchBar.text = nil
            searchBar.setShowsCancelButton(false, animated: false)
            filterDelegate?.freeTextFilterViewController(self, didChangeText: nil)
        }

        returnToSuperView()
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let filter = filter else { return }
        // If not active, the user clicked the x-button while not editing and the search should be cancelled
        if !searchBar.isDescendant(of: view), searchText.isEmpty {
            didClearText = true
            delegate?.freeTextFilterViewController(self, didSelectValue: nil, forFilter: filter)
            currentQuery = nil
            filterDelegate?.freeTextFilterViewController(self, didChangeText: nil)
            return
        }
        // If the user clears the search field and then hits cancel, the search is cancelled
        if let _ = currentQuery, searchText.isEmpty {
            currentQuery = nil
        }

        filterDelegate?.freeTextFilterViewController(self, didChangeText: searchText)
    }
}

// MARK: - Private methods

private extension FreeTextFilterViewController {
    func returnToSuperView() {
        searchBar.endEditing(false)
        searchBar.setShowsCancelButton(false, animated: false)
        delegate?.freeTextFilterViewControllerWillEndEditing(self)
    }

    func setup() {
        searchBar.removeFromSuperview()
        view.addSubview(searchBar)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .mediumSpacing),
            searchBar.topAnchor.constraint(equalTo: view.topAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.mediumSpacing),

            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

private class SearchQuerySearchBar: UISearchBar {
    // Makes sure to setup appearance proxy one time and one time only
    private static let setupSearchQuerySearchBarAppereanceOnce: () = {
        let textFieldAppearanceInRoot = UITextField.appearance(whenContainedInInstancesOf: [UITableViewCell.self])
        textFieldAppearanceInRoot.defaultTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.primaryBlue,
            NSAttributedString.Key.font: UIFont.regularBody,
        ]

        let textFieldAppearanceInSearch = UITextField.appearance(whenContainedInInstancesOf: [SearchQuerySearchBar.self])
        textFieldAppearanceInSearch.defaultTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.licorice,
            NSAttributedString.Key.font: UIFont.regularBody,
        ]

        let barButtondAppearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [SearchQuerySearchBar.self])
        barButtondAppearance.title = "cancel".localized()
    }()

    override init(frame: CGRect) {
        _ = SearchQuerySearchBar.setupSearchQuerySearchBarAppereanceOnce
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        _ = SearchQuerySearchBar.setupSearchQuerySearchBarAppereanceOnce
        super.init(coder: aDecoder)
    }
}
