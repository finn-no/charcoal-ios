//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class FreeTextFilterCell: UITableViewCell {
    private var searchBar: UISearchBar?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func configure(with searchBar: UISearchBar) {
        self.searchBar = searchBar
        setupSearchBar(searchBar)
    }
}

private extension FreeTextFilterCell {
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
