//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import UIKit

final class PreferenceSelectionViewDemoView: UIView {
    lazy var demoView: PreferenceSelectionView = {
        let view = PreferenceSelectionView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.load(verticals: [], preferences: PreferenceSelectionViewDemoView.preferenceFilters)
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

extension PreferenceSelectionViewDemoView {
    static var preferenceFilters: [PreferenceInfoDemo] {
        return [
            PreferenceInfoDemo(preferenceName: "Type søk", values:
                [
                    PreferenceValueTypeDemo(title: "Til salgs", value: "1", results: 1),
                    PreferenceValueTypeDemo(title: "Gis bort", value: "2", results: 1),
                    PreferenceValueTypeDemo(title: "Ønskes kjøpt", value: "3", results: 1),
            ], isMultiSelect: true, title: "Type søk"),
            PreferenceInfoDemo(preferenceName: "Tilstand", values:
                [
                    PreferenceValueTypeDemo(title: "Alle", value: "0", results: 1),
                    PreferenceValueTypeDemo(title: "Brukt", value: "2", results: 1),
                    PreferenceValueTypeDemo(title: "Nytt", value: "3", results: 1),
            ], isMultiSelect: false, title: "Tilstand"),
            PreferenceInfoDemo(preferenceName: "Selger", values:
                [
                    PreferenceValueTypeDemo(title: "Alle", value: "0", results: 1),
                    PreferenceValueTypeDemo(title: "Forhandler", value: "2", results: 1),
                    PreferenceValueTypeDemo(title: "Privat", value: "3", results: 1),
            ], isMultiSelect: false, title: "Selger"),
            PreferenceInfoDemo(preferenceName: "Publisert", values:
                [PreferenceValueTypeDemo(title: "Nye i dag", value: "1", results: 1)], isMultiSelect: false, title: "Publisert"),
        ]
    }
}

extension PreferenceSelectionViewDemoView: PreferenceSelectionViewDelegate {
    func preferenceSelectionView(_ preferenceSelectionView: PreferenceSelectionView, didTapExpandablePreferenceAtIndex index: Int, view: ExpandableSelectionButton) {
        print("Button at index \(index) with title \(PreferenceSelectionViewDemoView.preferenceFilters[index].title) was tapped")
        view.isSelected = true
    }
}
