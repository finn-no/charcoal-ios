//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit
import UIKit

final class PreferenceSelectionViewDemoView: UIView {
    lazy var demoView: PreferenceSelectionView = {
        let view = PreferenceSelectionView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.dataSource = self
        view.delegate = self
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        addSubview(demoView)

        NSLayoutConstraint.activate([
            demoView.topAnchor.constraint(equalTo: topAnchor, constant: .mediumLargeSpacing),
            demoView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            demoView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            demoView.heightAnchor.constraint(equalToConstant: PreferenceSelectionView.defaultButtonHeight),
        ])
    }
}

extension PreferenceSelectionViewDemoView: PreferenceSelectionViewDataSource {
    static var titles = ["Type søk", "Tilstand", "Selger", "Publisert"]

    func preferenceSelectionView(_ preferenceSelectionView: PreferenceSelectionView, titleForPreferenceAtIndex index: Int) -> String? {
        return PreferenceSelectionViewDemoView.titles[index]
    }

    func numberOfPreferences(_ preferenceSelectionView: PreferenceSelectionView) -> Int {
        return PreferenceSelectionViewDemoView.titles.count
    }
}

extension PreferenceSelectionViewDemoView: PreferenceSelectionViewDelegate {
    func preferenceSelectionView(_ preferenceSelectionView: PreferenceSelectionView, didTapPreferenceAtIndex index: Int) {
        print("Button at index \(index) with title \(PreferenceSelectionViewDemoView.titles[index]) was tapped")
        let isSelected = preferenceSelectionView.isPreferenceSelected(at: index)
        preferenceSelectionView.setPreference(at: index, selected: !isSelected)
    }
}
