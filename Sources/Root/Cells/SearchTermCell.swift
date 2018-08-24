//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol SearchTermCellDelegate: AnyObject {
    func searchTermCellDidTapSearchBar(_ searchTermCell: SearchTermCell)
    func searchTermCellDidTapRemoveSelectedValue(_ searchTermCell: SearchTermCell)
}

class SearchTermCell: UITableViewCell {
    weak var delegate: SearchTermCellDelegate?

    private lazy var searchBar: UISearchBar = {
        let searchBar = SearchTermCellSearchBar(frame: .zero)
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        return searchBar
    }()

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
        searchText = nil
        placeholderText = nil
    }
}

private extension SearchTermCell {
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

extension SearchTermCell: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if !hasTappedClearButton {
            delegate?.searchTermCellDidTapSearchBar(self)
        }
        hasTappedClearButton = false
        return false
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchTermCellDidTapRemoveSelectedValue(self)
        hasTappedClearButton = true
    }
}

extension SearchTermCell {
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

private extension SearchTermCell {
    class SearchTermCellSearchBar: UISearchBar {
        // Makes sure to setup appearance proxy one time and one time only
        private static let setupSearchTermSearchBarAppereanceOnce: () = {
            let appearance = UITextField.appearance(whenContainedInInstancesOf: [SearchTermCellSearchBar.self])
            appearance.defaultTextAttributes = [
                NSAttributedStringKey.foregroundColor.rawValue: UIColor.primaryBlue,
                NSAttributedStringKey.font.rawValue: UIFont.title4,
            ]
        }()

        override init(frame: CGRect) {
            _ = SearchTermCellSearchBar.setupSearchTermSearchBarAppereanceOnce
            super.init(frame: frame)
        }

        required init?(coder aDecoder: NSCoder) {
            _ = SearchTermCellSearchBar.setupSearchTermSearchBarAppereanceOnce
            super.init(coder: aDecoder)
        }
    }
}
