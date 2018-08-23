//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol FreeTextCellDelegate: AnyObject {
    func freeTextCellDidTapSearchBar(_ freeTextCell: FreeTextCell)
    func freeTextCellDidTapRemoveSelectedValue(_ freeTextCell: FreeTextCell)
}

class FreeTextCell: UITableViewCell {
    weak var delegate: FreeTextCellDelegate?

    private lazy var searchBar: UISearchBar = {
        let searchBar = FreeTextSearchBar(frame: .zero)
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

private extension FreeTextCell {
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

extension FreeTextCell: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if !hasTappedClearButton {
            delegate?.freeTextCellDidTapSearchBar(self)
        }
        hasTappedClearButton = false
        return false
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.freeTextCellDidTapRemoveSelectedValue(self)
        hasTappedClearButton = true
    }
}

extension FreeTextCell {
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

fileprivate class FreeTextSearchBar: UISearchBar {
    // Makes sure to setup appearance proxy one time and one time only
    private static let setupFreeTextSearchBarAppereanceOnce: () = {
        let appearance = UITextField.appearance(whenContainedInInstancesOf: [FreeTextSearchBar.self])
        appearance.defaultTextAttributes = [
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.primaryBlue,
            NSAttributedStringKey.font.rawValue: UIFont.title4,
        ]
    }()

    override init(frame: CGRect) {
        _ = FreeTextSearchBar.setupFreeTextSearchBarAppereanceOnce
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        _ = FreeTextSearchBar.setupFreeTextSearchBarAppereanceOnce
        super.init(coder: aDecoder)
    }
}
