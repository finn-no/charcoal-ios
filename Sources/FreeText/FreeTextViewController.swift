//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public class FreeTextViewController: UIViewController, FilterContainerViewController {
    public var filterSelectionDelegate: FilterContainerViewControllerDelegate?

    public var controller: UIViewController {
        return self
    }

    private var startText: String?

    private var placeholder: String?

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: .zero)
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
        tableView.register(UITableViewCell.self)

        return tableView
    }()

    public required convenience init?(filterInfo: FilterInfoType) {
        guard let freeTextFilterInfoType = filterInfo as? FreeTextFilterInfoType else {
            return nil
        }

        self.init(title: freeTextFilterInfoType.name, startText: freeTextFilterInfoType.value, placeholder: freeTextFilterInfoType.placeholderText)
    }

    public init(title: String?, startText: String?, placeholder: String?) {
        self.startText = startText
        self.placeholder = placeholder
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setSelectionValue(_ selectionValue: FilterSelectionValue) {
        guard case let .singleSelection(value) = selectionValue else {
            return
        }
        searchText = value
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        searchBar.becomeFirstResponder()
    }

    public func showSuggestions(_ suggestions: [String], for searchText: String) {
        if searchText == searchText {
            self.suggestions = suggestions
            suggestionsTableView.reloadData()
        }
    }
}

extension FreeTextViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        suggestions.removeAll()
        suggestionsTableView.reloadData()
        filterSelectionDelegate?.filterContainerViewController(filterContainerViewController: self, didUpdateFilterSelectionValue: .singleSelection(value: searchText ?? ""))
    }
}

extension FreeTextViewController: UISearchBarDelegate {
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filterSelectionDelegate?.filterContainerViewController(filterContainerViewController: self, didUpdateFilterSelectionValue: .singleSelection(value: startText ?? ""))
        navigationController?.popViewController(animated: true)
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filterSelectionDelegate?.filterContainerViewController(filterContainerViewController: self, didUpdateFilterSelectionValue: .singleSelection(value: searchText ?? ""))
        navigationController?.popViewController(animated: true)
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        suggestions.removeAll()
        suggestionsTableView.reloadData()
        filterSelectionDelegate?.filterContainerViewController(filterContainerViewController: self, didUpdateFilterSelectionValue: .singleSelection(value: searchText))
    }
}

extension FreeTextViewController: UITableViewDataSource {
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

extension FreeTextViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let suggestion = suggestions[safe: indexPath.row] {
            filterSelectionDelegate?.filterContainerViewController(filterContainerViewController: self, didUpdateFilterSelectionValue: .singleSelection(value: suggestion))
        }
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return type(of: self).rowHeight
    }
}

private extension FreeTextViewController {
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
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            suggestionsTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            suggestionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            suggestionsTableView.bottomAnchor.constraint(equalTo: safeBottomAnchor),
            suggestionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}
