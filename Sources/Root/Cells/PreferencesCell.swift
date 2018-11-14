//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class PreferencesCell: UITableViewCell {
    private var preferences: [PreferenceFilterInfoType]?

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
        preferenceSelectionView.delegate = nil
        preferenceSelectionView.load(verticals: [], preferences: [])
    }

    func setupWith(verticals: [Vertical], preferences: [PreferenceFilterInfoType], delegate: PreferenceSelectionViewDelegate, selectionDataSource: FilterSelectionDataSource) {
        preferenceSelectionView.delegate = delegate
        preferenceSelectionView.selectionDataSource = selectionDataSource

        let previousVerticals = preferenceSelectionView.verticals
        let previousPreferences = preferenceSelectionView.preferences

        var dataChanged = verticals.count != previousVerticals.count || preferences.count != previousPreferences.count

        if !dataChanged {
            dataChanged = previousVerticals.elementsEqual(verticals) { (lhs, rhs) -> Bool in
                return lhs.title == rhs.title
            }
        }

        if !dataChanged {
            dataChanged = previousPreferences.elementsEqual(preferences) { (lhs, rhs) -> Bool in
                return lhs.preferenceName == rhs.preferenceName && lhs.title == rhs.title && lhs.values.count == rhs.values.count && lhs.values.elementsEqual(rhs.values, by: { $0.value == $1.value })
            }
        }
        if dataChanged {
            preferenceSelectionView.load(verticals: verticals, preferences: preferences)
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
