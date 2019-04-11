//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal

final class InlineFilterDemoViewController: DemoViewController {
    private let filter = Filter.inline(title: "Inline Filter", key: "", subfilters: [
        Filter.inline(title: "", key: "", subfilters: [
            Filter.inline(title: "Til Salgs", key: "", subfilters: []),
            Filter.inline(title: "Gis Bort", key: "", subfilters: []),
            Filter.inline(title: "Ønsket Kjøpt", key: "", subfilters: []),
        ]),
        Filter.inline(title: "", key: "", subfilters: [
            Filter.inline(title: "Brukt", key: "", subfilters: []),
            Filter.inline(title: "Nytt", key: "", subfilters: []),
        ]),
        Filter.inline(title: "", key: "", subfilters: [
            Filter.inline(title: "Forhandler", key: "", subfilters: []),
            Filter.inline(title: "Private", key: "", subfilters: []),
        ]),
        Filter.inline(title: "", key: "", subfilters: [
            Filter.inline(title: "Nye i dag", key: "", subfilters: []),
        ]),
    ])

    private lazy var inlineFilterView: InlineFilterView = {
        let view = InlineFilterView(withAutoLayout: true)

        let titles = filter.subfilters.map({
            $0.subfilters.map({
                $0.title
            })
        })

        view.configure(withTitles: titles, verticalTitle: "Vertical", selectedItems: [[], [], [], []])
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(inlineFilterView)
        NSLayoutConstraint.activate([
            inlineFilterView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            inlineFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inlineFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

extension InlineFilterDemoViewController: InlineFilterViewDelegate {
    func inlineFilterView(_ inlineFilterview: InlineFilterView, didTapExpandableSegment segment: Segment) {
        return
    }

    func inlineFilterView(_ inlineFilterView: InlineFilterView, didChange segment: Segment, at index: Int) {
        return
    }
}
