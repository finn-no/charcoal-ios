//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol SearchQueryCellDelegate: AnyObject {
    func searchQueryCellDidTapSearchBar(_ searchQueryCell: SearchQueryCell)
    func searchQueryCellDidTapRemoveSelectedValue(_ searchQueryCell: SearchQueryCell)
}

class SearchQueryCell: UITableViewCell {
    weak var delegate: SearchQueryCellDelegate?

    private lazy var searchResultsViewController = UIViewController(nibName: nil, bundle: nil)

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: self.searchResultsViewController)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.text = "Test"
        searchController.searchBar.delegate = self

        return searchController
    }()

    private var searchBar: UISearchBar {
        return searchController.searchBar
    }

    private var hasTappedClearButton = false

    override var textLabel: UILabel? {
        return nil
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        searchQuery = nil
        placeholderText = nil
    }
}

private extension SearchQueryCell {
    func setup() {
        selectionStyle = .none

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: contentView.topAnchor),
            searchBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
}

extension SearchQueryCell: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if !hasTappedClearButton {
            delegate?.searchQueryCellDidTapSearchBar(self)
        }
        hasTappedClearButton = false
        return false
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchQueryCellDidTapRemoveSelectedValue(self)
        hasTappedClearButton = true
    }
}

extension SearchQueryCell {
    var searchQuery: String? {
        get {
            return searchBar.text
        }
        set {
            searchBar.text = newValue
        }
    }

    var placeholderText: String? {
        get {
            return searchBar.placeholder
        }
        set {
            searchBar.placeholder = newValue
        }
    }
}
