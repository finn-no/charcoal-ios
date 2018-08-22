//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol QueryViewControllerDelegate: AnyObject {
    func queryViewController(_ queryViewController: QueryViewController, didChangeQuery query: String?)
    func queryViewController(_ queryViewController: QueryViewController, didChooseSuggestion suggestion: String)
}

public class QueryViewController: UIViewController {
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.searchBarStyle = .minimal

        return searchController
    }()

    private static var rowHeight: CGFloat = 48.0

    private var suggestions = [String]()

    private lazy var suggestionsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = false
        tableView.register(UITableViewCell.self)

        return tableView
    }()

    public weak var delegate: QueryViewControllerDelegate?

    public init(title: String, query: String?) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    public func showSuggestions(_ suggestions: [String], for query: String) {
        if currentQuery == query {
            self.suggestions = suggestions
            suggestionsTableView.reloadData()
        }
    }
}

extension QueryViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        suggestions.removeAll()
        suggestionsTableView.reloadData()
        delegate?.queryViewController(self, didChangeQuery: searchController.searchBar.text)
    }
}

extension QueryViewController: UISearchControllerDelegate {
}

extension QueryViewController: UISearchBarDelegate {
}

extension QueryViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UITableViewCell.self, for: indexPath)
        let suggestion = suggestions[safe: indexPath.row]
        cell.textLabel?.text = suggestion
        return cell
    }
}

extension QueryViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let suggestion = suggestions[safe: indexPath.row] {
            delegate?.queryViewController(self, didChooseSuggestion: suggestion)
        }
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return type(of: self).rowHeight
    }
}

private extension QueryViewController {
    var currentQuery: String? {
        set {
            searchController.searchBar.text = newValue
        }
        get {
            return searchController.searchBar.text
        }
    }

    func setup() {
        view.backgroundColor = .milk
        view.addSubview(searchController.searchBar)
        view.addSubview(suggestionsTableView)

        NSLayoutConstraint.activate([
            searchController.searchBar.topAnchor.constraint(equalTo: safeTopAnchor),
            searchController.searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchController.searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            suggestionsTableView.topAnchor.constraint(equalTo: searchController.searchBar.bottomAnchor),
            suggestionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            suggestionsTableView.bottomAnchor.constraint(equalTo: safeBottomAnchor),
            suggestionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}
