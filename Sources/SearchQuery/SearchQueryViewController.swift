//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol SearchQuerySuggestionsDataSource: AnyObject {
    func searchQueryViewController(_ searchQueryViewController: SearchQueryViewController, didRequestSuggestionsFor searchQuery: String, completion: @escaping ((_ text: String, _ suggestions: [String]) -> Void))
}

public class SearchQueryViewController: UIViewController, FilterContainerViewController {
    public var searchQuerySuggestionsDataSource: SearchQuerySuggestionsDataSource?
    public var filterSelectionDelegate: FilterContainerViewControllerDelegate?

    public var controller: UIViewController {
        return self
    }

    private var startText: String?

    private var placeholder: String?

    private lazy var searchBar: UISearchBar = {
        let searchBar = SearchQueryViewControllerSearchBar(frame: .zero)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.showsScopeBar = false
        searchBar.text = startText
        searchBar.placeholder = placeholder
        searchBar.delegate = self
        searchBar.sizeToFit()
        return searchBar
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
        tableView.register(SearchQuerySuggestionCell.self)

        return tableView
    }()

    private let searchQueryFilterInfo: SearchQueryFilterInfoType
    private let selectionDataSource: FilterSelectionDataSource

    public required init?(filterInfo: FilterInfoType, selectionDataSource: FilterSelectionDataSource) {
        guard let searchQueryFilterInfo = filterInfo as? SearchQueryFilterInfoType else {
            return nil
        }
        self.searchQueryFilterInfo = searchQueryFilterInfo
        self.selectionDataSource = selectionDataSource
        startText = searchQueryFilterInfo.value
        placeholder = searchQueryFilterInfo.placeholderText
        super.init(nibName: nil, bundle: nil)
        title = searchQueryFilterInfo.title
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        if let selectionValue = selectionDataSource.value(for: searchQueryFilterInfo) {
            setSelectionValue(selectionValue)
        }

        setup()
        searchBar.becomeFirstResponder()
    }
}

extension SearchQueryViewController: UISearchBarDelegate {
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        selectionDataSource.setValue([startText ?? ""], for: searchQueryFilterInfo)
        navigationController?.popViewController(animated: true)
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        selectionDataSource.setValue([searchText ?? ""], for: searchQueryFilterInfo)
        navigationController?.popViewController(animated: true)
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        suggestions.removeAll()
        suggestionsTableView.reloadData()
        searchQuerySuggestionsDataSource?.searchQueryViewController(self, didRequestSuggestionsFor: searchText, completion: { text, suggestions in
            DispatchQueue.main.async {
                if searchText == text {
                    self.suggestions = suggestions
                    self.suggestionsTableView.reloadData()
                }
            }
        })
    }
}

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

extension SearchQueryViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let suggestion = suggestions[safe: indexPath.row] {
            searchText = suggestion
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return type(of: self).rowHeight
    }
}

private extension SearchQueryViewController {
    var searchText: String? {
        set {
            searchBar.text = newValue
        }
        get {
            return searchBar.text
        }
    }

    func setup() {
        view.backgroundColor = .milk
        view.addSubview(searchBar)
        view.addSubview(suggestionsTableView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: safeTopAnchor),
            searchBar.layoutMarginsGuide.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            searchBar.layoutMarginsGuide.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            suggestionsTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            suggestionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            suggestionsTableView.bottomAnchor.constraint(equalTo: safeBottomAnchor),
            suggestionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    func setSelectionValue(_ selectionValues: [String]?) {
        guard let value = selectionValues?.first else {
            return
        }
        searchText = value
    }
}

// MARK: - Private class

private extension SearchQueryViewController {
    class SearchQueryViewControllerSearchBar: UISearchBar {
        // Makes sure to setup appearance proxy one time and one time only
        private static let setupSearchQuerySearchBarAppereanceOnce: () = {
            let appearance = UITextField.appearance(whenContainedInInstancesOf: [SearchQueryViewControllerSearchBar.self])
            appearance.defaultTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.licorice,
                NSAttributedString.Key.font: UIFont.regularBody,
            ]
        }()

        override init(frame: CGRect) {
            _ = SearchQueryViewControllerSearchBar.setupSearchQuerySearchBarAppereanceOnce
            super.init(frame: frame)
        }

        required init?(coder aDecoder: NSCoder) {
            _ = SearchQueryViewControllerSearchBar.setupSearchQuerySearchBarAppereanceOnce
            super.init(coder: aDecoder)
        }
    }
}
