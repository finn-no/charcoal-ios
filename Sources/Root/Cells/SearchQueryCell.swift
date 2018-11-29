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
        searchBar.removeFromSuperview()
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

class SearchQueryCellSearchBar: UISearchBar {
    // Makes sure to setup appearance proxy one time and one time only
    private static let setupSearchQuerySearchBarAppereanceOnce: () = {
        let textFieldAppearanceInRoot = UITextField.appearance(whenContainedInInstancesOf: [UITableViewCell.self])
        textFieldAppearanceInRoot.defaultTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.primaryBlue,
            NSAttributedString.Key.font: UIFont.regularBody,
        ]

        let textFieldAppearanceInSearch = UITextField.appearance(whenContainedInInstancesOf: [SearchQueryViewController.self])
        textFieldAppearanceInSearch.defaultTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.licorice,
            NSAttributedString.Key.font: UIFont.regularBody,
        ]

        let barButtondAppearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [SearchQueryCellSearchBar.self])
        barButtondAppearance.title = "cancel".localized()
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
