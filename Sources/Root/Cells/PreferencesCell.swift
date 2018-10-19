//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class PreferencesCell: UITableViewCell {
    private var preferences: [PreferenceInfoType]?

    private lazy var preferenceSelectionView: PreferenceSelectionView = {
        let view = PreferenceSelectionView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

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
        preferenceSelectionView.preferences = nil
        preferenceSelectionView.delegate = nil
    }

    func setupWith(preferences: [PreferenceInfoType], delegate: PreferenceSelectionViewDelegate, selectionDataSource: FilterSelectionDataSource) {
        preferenceSelectionView.delegate = delegate
        preferenceSelectionView.selectionDataSource = selectionDataSource

        var preferencesChanged = true
        if let previousPreferences = preferenceSelectionView.preferences {
            preferencesChanged = previousPreferences.elementsEqual(preferences) { (lhs, rhs) -> Bool in
                return lhs.preferenceName == rhs.preferenceName && lhs.title == rhs.title && lhs.values.elementsEqual(rhs.values, by: { $0.value == $1.value })
            }
        }
        if preferencesChanged {
            preferenceSelectionView.preferences = preferences
        }
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
