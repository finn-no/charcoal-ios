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

final class SelectionTagsContainerView: UIView, CurrentSelectionValuesContainer {
    var delegate: CurrentSelectionValuesContainerDelegate?
    private let selectionContainerHeight: CGFloat = 30

    private lazy var collapsedView: SelectionTagsCollapsedView = {
        let view = SelectionTagsCollapsedView(withAutoLayout: true)
        view.delegate = self
        return view
    }()

    private lazy var expandedView: SelectionTagsExpandedView = {
        let view = SelectionTagsExpandedView(withAutoLayout: true)
        view.delegate = self
        return view
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Overrides

    override func layoutSubviews() {
        expandedView.layoutIfNeeded()

        let showCollapsedView = frame.width < expandedView.frame.width
        expandedView.isHidden = showCollapsedView
        collapsedView.isHidden = !showCollapsedView

        super.layoutSubviews()
    }

    // MARK: - Setup

    func configure(with selectedValues: [SelectionWithTitle]?) {
        collapsedView.configure(with: selectedValues)
        expandedView.configure(with: selectedValues)
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
}

// MARK: - CurrentSelectionValuesContainerDelegate

extension SelectionTagsContainerView: CurrentSelectionValuesContainerDelegate {
    func currentSelectionValuesContainerView(_ container: CurrentSelectionValuesContainer, didTapRemoveSelection selection: SelectionWithTitle) {
        delegate?.currentSelectionValuesContainerView(container, didTapRemoveSelection: selection)
    }
}
