//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class SearchQueryCell: UITableViewCell, Identifiable {
    private lazy var searchResultsViewController = UIViewController(nibName: nil, bundle: nil)

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: self.searchResultsViewController)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal

        return searchController
    }()

    private var searchBar: UISearchBar {
        return searchController.searchBar
    }

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

        searchBar.isUserInteractionEnabled = false
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
