//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import UIKit

public protocol SearchQuerySuggestionsDataSource: AnyObject {
    func searchQueryViewController(_ searchQueryViewController: SearchQueryViewController, didRequestSuggestionsFor searchQuery: String, completion: @escaping ((_ text: String, _ suggestions: [String]) -> Void))
}

public protocol SearchViewControllerDelegate: class {
    func presentSearchViewController(_ searchViewController: SearchQueryViewController)
    func searchViewControllerDidCancelSearch(_ searchViewController: SearchQueryViewController)
    func searchViewController(_ searchViewController: SearchQueryViewController, didSelectQuery query: String?)
}

public class SearchQueryViewController: UIViewController {

    // MARK: - Public Properties

    public weak var delegate: SearchViewControllerDelegate?
    public var searchQuerySuggestionDataSource: SearchQuerySuggestionsDataSource?

    // MARK: - Private Properties

    private var suggestions: [String] = []
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
}

// MARK: - TableView DataSource

extension SearchQueryViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(IconTitleTableViewCell.self, for: indexPath)
        let suggestion = suggestions[safe: indexPath.row]
        cell.titleLabel.font = .regularBody
        cell.configure(with: SearchQueryItemCellModel(title: suggestion ?? ""))
        cell.separatorInset = .leadingInset(48)
        return cell
    }
}

// MARK: - TableView Delegate

extension SearchQueryViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let query = suggestions[safe: indexPath.row]
        searchBar.text = query
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.searchViewController(self, didSelectQuery: query)
        currentQuery = query
        returnToSuperView()
    }
}

// MARK: - SearchBar Delegate

extension SearchQueryViewController: UISearchBarDelegate {
    public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // User clicked the x-button and cleared the text -> should not begin editing
        guard !didClearText else {
            didClearText = false
            return false
        }
        // Present if needed
        if searchBar.superview != view {
            setup()
            delegate?.presentSearchViewController(self)
        }
        return true
    }

    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: false)
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        delegate?.searchViewController(self, didSelectQuery: searchBar.text)
        currentQuery = searchBar.text
        returnToSuperView()
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if let currentQuery = currentQuery {
            // return to previous search
            delegate?.searchViewController(self, didSelectQuery: nil)
            searchBar.text = currentQuery
            suggestions(forSearchText: currentQuery)
        } else {
            delegate?.searchViewControllerDidCancelSearch(self)
            currentQuery = nil
            searchBar.text = nil
            searchBar.setShowsCancelButton(false, animated: false)
            suggestions(forSearchText: nil)
        }
        returnToSuperView()
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // If not active, the user clicked the x-button while not editing and the search should be cancelled
        if !searchBar.isDescendant(of: view), searchText.isEmpty {
            didClearText = true
            delegate?.searchViewControllerDidCancelSearch(self)
            currentQuery = nil
            suggestions(forSearchText: nil)
            return
        }
        // If the user clears the search field and then hits cancel, the search is cancelled
        if let _ = currentQuery, searchText.isEmpty {
            currentQuery = nil
        }
        suggestions(forSearchText: searchText)
    }
}

// MARK: - Private methods

private extension SearchQueryViewController {
    func returnToSuperView() {
        searchBar.endEditing(false)
        searchBar.setShowsCancelButton(false, animated: false)
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }

    func suggestions(forSearchText searchText: String?) {
        suggestions.removeAll()
        tableView.reloadData()
        guard let searchText = searchText, !searchText.isEmpty else { return }
        searchQuerySuggestionDataSource?.searchQueryViewController(self, didRequestSuggestionsFor: searchText, completion: { [weak self] text, suggestions in
            DispatchQueue.main.async {
                guard let query = self?.searchBar.text else { return }
                if query == text {
                    self?.suggestions = suggestions
                    self?.tableView.reloadData()
                }
            }
        })
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

// MARK: - Private class

private struct SearchQueryItemCellModel: IconTitleTableViewCellViewModel {
    let detailText: String? = nil

    var title: String

    var icon: UIImage? {
        return UIImage(named: .searchSmall)
    }

    var iconTintColor: UIColor? {
        return nil
    }

    var subtitle: String? {
        return nil
    }

    var hasChevron: Bool {
        return false
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
