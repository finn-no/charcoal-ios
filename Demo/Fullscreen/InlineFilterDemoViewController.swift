//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//
import Charcoal
import UIKit

final class InlineFilterDemoViewController: UIViewController {
    lazy var inlineFilterView: InlineFilterView = {
        let view = InlineFilterView(verticals: verticalSetup(), preferences: InlineFilterDemoViewController.preferenceFilters)
        view.inlineFilterDelegate = self
        view.contentInset = UIEdgeInsets(top: 0, left: .mediumLargeSpacing, bottom: 0, right: .mediumLargeSpacing)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var popoverPresentationTransitioningDelegate = CustomPopoverPresentationTransitioningDelegate()

    var selectionDataSource: FilterSelectionDataSource? {
        get { return inlineFilterView.selectionDataSource }
        set { inlineFilterView.selectionDataSource = selectionDataSource }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func setup() {
        view.backgroundColor = .white
        view.addSubview(inlineFilterView)
        NSLayoutConstraint.activate([
            inlineFilterView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            inlineFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inlineFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inlineFilterView.heightAnchor.constraint(equalToConstant: 54),
        ])
    }
}

extension InlineFilterDemoViewController {
    static var preferenceFilters: [PreferenceInfoDemo] {
        return [
            PreferenceInfoDemo(title: "Type søk", values:
                [
                    PreferenceValueTypeDemo(title: "Til salgs", value: "1", results: 1),
                    PreferenceValueTypeDemo(title: "Gis bort", value: "2", results: 1),
                    PreferenceValueTypeDemo(title: "Ønskes kjøpt", value: "3", results: 1),
            ], isMultiSelect: true),
            PreferenceInfoDemo(title: "Tilstand", values:
                [
                    PreferenceValueTypeDemo(title: "Alle", value: "0", results: 1),
                    PreferenceValueTypeDemo(title: "Brukt", value: "2", results: 1),
                    PreferenceValueTypeDemo(title: "Nytt", value: "3", results: 1),
            ], isMultiSelect: false),
            PreferenceInfoDemo(title: "Selger", values:
                [
                    PreferenceValueTypeDemo(title: "Alle", value: "0", results: 1),
                    PreferenceValueTypeDemo(title: "Forhandler", value: "2", results: 1),
                    PreferenceValueTypeDemo(title: "Privat", value: "3", results: 1),
            ], isMultiSelect: false),
            PreferenceInfoDemo(title: "Publisert", values:
                [
                    PreferenceValueTypeDemo(title: "Nye i dag", value: "1", results: 1),
            ], isMultiSelect: false),
        ]
    }
}

extension InlineFilterDemoViewController: InlineFilterViewDelegate {
    func inlineFilterView(_ inlineFilterView: InlineFilterView, didTapExpandableSegment segment: Segment) {
        let popover = VerticalListViewController(verticals: verticalSetup())
        popover.preferredContentSize = CGSize(width: view.frame.size.width, height: 144)
        popover.modalPresentationStyle = .custom
        popoverPresentationTransitioningDelegate.sourceView = segment
        popoverPresentationTransitioningDelegate.willDismissPopoverHandler = { _ in
            segment.selectedItems = []
        }
        popover.transitioningDelegate = popoverPresentationTransitioningDelegate
        present(popover, animated: true, completion: nil)
    }

    func verticalSetup() -> [VerticalDemo] {
        let verticalsRealestateHomes = [
            VerticalDemo(id: "realestate-homes", title: "Bolig til salgs", isCurrent: true, isExternal: false, file: nil),
            VerticalDemo(id: "realestate-development", title: "Nye boliger", isCurrent: false, isExternal: false, file: nil),
            VerticalDemo(id: "realestate-plot", title: "Boligtomter", isCurrent: false, isExternal: false, file: nil),
            VerticalDemo(id: "realestate-leisure-sale", title: "Fritidsbolig til salgs", isCurrent: false, isExternal: false, file: nil),
            VerticalDemo(id: "realestate-leisure-sale-abroad", title: "Bolig i utlandet", isCurrent: false, isExternal: false, file: nil),
            VerticalDemo(id: "realestate-leisure-plot", title: "Fritidstomter", isCurrent: false, isExternal: false, file: nil),
            VerticalDemo(id: "realestate-letting", title: "Bolig til leie", isCurrent: false, isExternal: false, file: nil),
            VerticalDemo(id: "realestate-letting-wanted", title: "Bolig ønskes leid", isCurrent: false, isExternal: false, file: nil),
            VerticalDemo(id: "realestate-business-sale", title: "Næringseiendom til salgs", isCurrent: false, isExternal: false, file: nil),
            VerticalDemo(id: "realestate-business-letting", title: "Næringseiendom til leie", isCurrent: false, isExternal: false, file: nil),
            VerticalDemo(id: "realestate-business-plot", title: "Næringstomt", isCurrent: false, isExternal: false, file: nil),
            VerticalDemo(id: "realestate-company-for-sale", title: "Bedrifter til salgs", isCurrent: false, isExternal: false, file: nil),
            VerticalDemo(id: "realestate-travel-fhh", title: "Feriehus og hytter", isCurrent: false, isExternal: true, file: nil),
        ]

        return verticalsRealestateHomes
    }
}

struct PreferenceInfoDemo: PreferenceFilterInfoType {
    var title: String
    var values: [FilterValueType]
    var isMultiSelect: Bool
}

struct PreferenceValueTypeDemo: FilterValueType {
    var title: String
    var value: String
    var results: Int
    var parentFilterInfo: FilterInfoType? {
        return nil
    }

    var lookupKey: FilterValueUniqueKey {
        return FilterValueUniqueKey(parameterName: "demo" + title, value: value)
    }

    var detail: String? {
        return String(results)
    }

    var showsDisclosureIndicator: Bool {
        return false
    }
}
