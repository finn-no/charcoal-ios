//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal

final class InlineFilterDemoViewController: UIViewController {
    lazy var inlineFilterView: InlineFilterView = {
        let view = InlineFilterView(frame: .zero)
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var popoverPresentationTransitioningDelegate = CustomPopoverPresentationTransitioningDelegate()

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

extension InlineFilterDemoViewController: InlineFilterViewDelegate {
    func inlineFilterView(_ inlineFilterview: InlineFilterView, didTapExpandableSegment segment: Segment) {
        return
    }

    func inlineFilterView(_ inlineFilterView: InlineFilterView, didChange segment: Segment, at index: Int) {
        return
    }
}
