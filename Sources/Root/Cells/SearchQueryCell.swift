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

    private lazy var searchBar: UISearchBar = {
        let searchBar = SearchQueryCellSearchBar(frame: .zero)
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        return searchBar
    }()

    private var hasTappedClearButton = false

    override var textLabel: UILabel? {
        return nil
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        searchText = nil
        placeholderText = nil
    }
}

private extension SearchQueryCell {
    func setup() {
        preservesSuperviewLayoutMargins = true
        contentView.preservesSuperviewLayoutMargins = true
        selectionStyle = .none

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: contentView.topAnchor),
            searchBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            searchBar.layoutMarginsGuide.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            searchBar.layoutMarginsGuide.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
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
    var searchText: String? {
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

// MARK: - Private class

private extension SearchQueryCell {
    class SearchQueryCellSearchBar: UISearchBar {
        // Makes sure to setup appearance proxy one time and one time only
        private static let setupSearchQuerySearchBarAppereanceOnce: () = {
            let appearance = UITextField.appearance(whenContainedInInstancesOf: [SearchQueryCellSearchBar.self])
            appearance.defaultTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.primaryBlue,
                NSAttributedString.Key.font: UIFont.title4,
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
