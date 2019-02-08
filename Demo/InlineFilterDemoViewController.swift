//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal

final class InlineFilterDemoViewController: UIViewController {
    lazy var inlineFilterView: CCInlineFilterView = {
        let view = CCInlineFilterView()
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

extension InlineFilterDemoViewController: CCInlineFilterViewDelegate {
    func inlineFilterViewDidChangeValue(_ inlineFilterView: CCInlineFilterView) {
        return
    }
}
