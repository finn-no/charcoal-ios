//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class PreferencesCell: UITableViewCell {
    private lazy var preferenceSelectionView: PreferenceSelectionView = {
        let view = PreferenceSelectionView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

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
        preferenceSelectionView.dataSource = nil
        preferenceSelectionView.delegate = nil
    }
}

private extension PreferencesCell {
    func setup() {
        accessoryType = .none
        contentView.clipsToBounds = false

        contentView.addSubview(preferenceSelectionView)
        NSLayoutConstraint.activate([
            preferenceSelectionView.heightAnchor.constraint(equalToConstant: PreferenceSelectionView.defaultButtonHeight),
            preferenceSelectionView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            preferenceSelectionView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            preferenceSelectionView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            preferenceSelectionView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
        ])
    }
}

extension PreferencesCell {
    var preferenceSelectionViewDataSource: PreferenceSelectionViewDataSource? {
        get {
            return preferenceSelectionView.dataSource
        }
        set {
            preferenceSelectionView.dataSource = newValue
        }
    }

    var preferenceSelectionViewDelegate: PreferenceSelectionViewDelegate? {
        get {
            return preferenceSelectionView.delegate
        }
        set {
            preferenceSelectionView.delegate = newValue
        }
    }
}
