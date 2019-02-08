//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol SelectionTagsContainerViewDelegate: AnyObject {
    func selectionTagsContainerView(_ view: SelectionTagsContainerView, didTapRemoveSelection selection: SelectionWithTitle)
}

final class SelectionTagsContainerView: UIView {
    weak var delegate: SelectionTagsContainerViewDelegate?
    private let tagViewHeight: CGFloat = 30
    private var selectedValues: [SelectionWithTitle]?

    private lazy var collapsedView = SelectionTagView(withAutoLayout: true)

    private lazy var expandedView: UIStackView = {
        let stackView = UIStackView(withAutoLayout: true)
        stackView.axis = .horizontal
        stackView.spacing = .smallSpacing
        stackView.backgroundColor = .clear
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        return stackView
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
        self.selectedValues = selectedValues

        collapsedView.configure(withTitle: selectedValues?.joinedTitles, showRemoveButton: false)
        expandedView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        selectedValues?.forEach { selectedValue in
            let view = SelectionTagView()
            view.configure(withTitle: selectedValue.title, showRemoveButton: true)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = selectedValue.selectionInfo.isValid ? .primaryBlue : .cherry
            view.delegate = self
            expandedView.addArrangedSubview(view)
        }
    }

    private func setup() {
        addSubview(expandedView)
        addSubview(collapsedView)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 44),

            expandedView.centerYAnchor.constraint(equalTo: centerYAnchor),
            expandedView.heightAnchor.constraint(equalToConstant: tagViewHeight),
            expandedView.trailingAnchor.constraint(equalTo: trailingAnchor),

            collapsedView.centerYAnchor.constraint(equalTo: centerYAnchor),
            collapsedView.heightAnchor.constraint(equalToConstant: tagViewHeight),
            collapsedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collapsedView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
        ])
    }
}

// MARK: - FilterTagViewDelegate

extension SelectionTagsContainerView: SelectionTagViewDelegate {
    func selectionTagViewDidSelectRemove(_ view: SelectionTagView) {
        guard let tappedIndex = expandedView.arrangedSubviews.index(of: view) else {
            return
        }

        guard let selection = selectedValues?[safe: tappedIndex] else {
            return
        }

        delegate?.selectionTagsContainerView(self, didTapRemoveSelection: selection)
    }
}

// MARK: - Private extensions

private extension Array where Element == SelectionWithTitle {
    var joinedTitles: String {
        let string = compactMap({ $0.title }).joined(separator: ", ")
        return count > 1 ? "(\(count)) \(string)" : string
    }
}
