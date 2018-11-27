//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol SearchViewControllerDelegate: class {
    func presentSearchViewController(_ searchViewController: SearchQueryViewController)
    func searchViewControllerDidCancelSearch(_ searchViewController: SearchQueryViewController)
    func searchViewController(_ searchViewController: SearchQueryViewController, didSelectQuery query: String?)
}

public class SearchQueryViewController: UIViewController {

    // MARK: - Public

    public weak var delegate: SearchViewControllerDelegate?
    public var searchQuerySuggestionDataSource: SearchQuerySuggestionsDataSource?

    private var suggestions: [String] = []
    private var currentQuery: String?

    var previousSizeMode: BottomSheetPresentationController.ContentSizeMode = .compact

    private(set) lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.cancelButtonText = "cancel".localized()
        searchBar.backgroundColor = .milk
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(SearchQuerySuggestionCell.self)
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
        let cell = tableView.dequeue(SearchQuerySuggestionCell.self, for: indexPath)
        let suggestion = suggestions[safe: indexPath.row]
        cell.suggestionLabel.text = suggestion
        return cell
    }
}

// MARK: - TableView Delegate

extension SearchQueryViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let query = suggestions[indexPath.row]
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
        view.removeFromSuperview()
        // Transition to compact mode if needed
        guard previousSizeMode == .compact, let presentationController = navigationController?.presentationController as? BottomSheetPresentationController else { return }
        presentationController.transition(to: .compact)
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

// MARK: - SearchBar Extensions

extension UISearchBar {
    var cancelButtonText: String {
        get { return value(forKey: "_cancelButtonText") as! String }
        set { setValue(newValue, forKey: "_cancelButtonText") }
    }
}
