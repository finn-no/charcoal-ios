//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal

final class InlineFilterDemoViewController: DemoViewController {

    // MARK: - Private properties

    private let titles = [
        ["Nye i dag"],
        ["Til Salg", "Gis Bort", "Ønsket Kjøpt"],
        ["Brukt", "Nytt"],
        ["Forhandler", "Privat"],
    ]

    private lazy var inlineFilterView: InlineFilterView = {
        let view = InlineFilterView(withAutoLayout: true)
        view.configure(withTitles: titles, selectedItems: [[], [], [], []])
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Life cycle

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
