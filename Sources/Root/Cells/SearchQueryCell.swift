//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class SearchQueryCell: UITableViewCell {
    var searchBar: UISearchBar? {
        didSet {
            setupSearchBar(searchBar)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}

private extension SearchQueryCell {
    func setupSearchBar(_ searchBar: UISearchBar?) {
        guard let searchBar = searchBar else { return }
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: contentView.topAnchor),
            searchBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .mediumSpacing),
            searchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.mediumSpacing),
        ])
    }

    func setup() {
        selectionStyle = .none
    }
}

// MARK: - Private class

private extension SearchQueryCell {
    class SearchQueryCellSearchBar: UISearchBar {
        // Makes sure to setup appearance proxy one time and one time only
        private static let setupSearchQuerySearchBarAppereanceOnce: () = {
            let appearance = UITextField.appearance(whenContainedInInstancesOf: [SearchQueryCellSearchBar.self])
            appearance.defaultTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.primaryBlue,
                NSAttributedString.Key.font: UIFont.regularBody,
            ]
        }()

        override init(frame: CGRect) {
            _ = SearchQueryCellSearchBar.setupSearchQuerySearchBarAppereanceOnce
            super.init(frame: frame)
        }

        required init?(coder aDecoder: NSCoder) {
            _ = SearchQueryCellSearchBar.setupSearchQuerySearchBarAppereanceOnce
            super.init(coder: aDecoder)
        }
    }
}
