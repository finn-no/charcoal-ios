//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol CurrentSelectionValuesContainer: AnyObject {
    var delegate: CurrentSelectionValuesContainerDelegate? { get set }
    func configure(with selectedValues: [SelectionWithTitle]?)
}

protocol CurrentSelectionValuesContainerDelegate: AnyObject {
    func currentSelectionValuesContainerView(_: CurrentSelectionValuesContainer, didTapRemoveSelection: SelectionWithTitle)
}

class CurrentSelectionValuesContainerView: UIView, CurrentSelectionValuesContainer, CurrentSelectionValuesContainerDelegate {
    private let selectionContainerHeight: CGFloat = 30

    private lazy var collapsedView: UIView & CurrentSelectionValuesContainer = {
        let view = CollapsedSelectionValuesView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var expandedView: UIView & CurrentSelectionValuesContainer = {
        let view = ExpandedSelectionValuesView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var delegate: CurrentSelectionValuesContainerDelegate?

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func layoutSubviews() {
        expandedView.layoutIfNeeded()
        let showCollapsedView = frame.width < expandedView.frame.width
        expandedView.isHidden = showCollapsedView
        collapsedView.isHidden = !showCollapsedView

        super.layoutSubviews()
    }

    private func setup() {
        addSubview(expandedView)
        addSubview(collapsedView)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 44),

            expandedView.centerYAnchor.constraint(equalTo: centerYAnchor),
            expandedView.heightAnchor.constraint(equalToConstant: selectionContainerHeight),
            expandedView.trailingAnchor.constraint(equalTo: trailingAnchor),

            collapsedView.centerYAnchor.constraint(equalTo: centerYAnchor),
            collapsedView.heightAnchor.constraint(equalToConstant: selectionContainerHeight),
            collapsedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collapsedView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
        ])
    }

    func currentSelectionValuesContainerView(_ container: CurrentSelectionValuesContainer, didTapRemoveSelection selection: SelectionWithTitle) {
        delegate?.currentSelectionValuesContainerView(container, didTapRemoveSelection: selection)
    }

    func configure(with selectedValues: [SelectionWithTitle]?) {
        collapsedView.configure(with: selectedValues)
        expandedView.configure(with: selectedValues)
    }
}
