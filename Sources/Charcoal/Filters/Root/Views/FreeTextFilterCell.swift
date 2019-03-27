//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class FreeTextFilterCell: UITableViewCell {

    // MARK: - Public properties

    let viewController: FreeTextFilterViewController

    init(viewController: FreeTextFilterViewController) {
        self.viewController = viewController
        super.init(style: .default, reuseIdentifier: nil)
        selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with searchBar: UISearchBar) {
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
}
