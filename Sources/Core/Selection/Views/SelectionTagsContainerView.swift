//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol SelectionTagsContainerViewDelegate: AnyObject {
    func selectionTagsContainerView(_ view: SelectionTagsContainerView, didRemoveTagAt index: Int)
    func selectionTagsContainerViewDidRemoveAllTags(_ view: SelectionTagsContainerView)
}

final class SelectionTagsContainerView: UIView {
    weak var delegate: SelectionTagsContainerViewDelegate?

    // MARK: - Private properties

    private lazy var collapsedView = SelectionTagView(withAutoLayout: true)

    private lazy var stackView: UIStackView = {
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
        stackView.layoutIfNeeded()

        let showCollapsedView = frame.width < stackView.frame.width
        stackView.isHidden = showCollapsedView
        collapsedView.isHidden = !showCollapsedView

        super.layoutSubviews()
    }

    // MARK: - Setup

    func configure(with selectionTitles: [String], isValid: Bool) {
        collapsedView.configure(withTitle: selectionTitles.joinedTitles, isValid: isValid)
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        selectionTitles.forEach { title in
            let view = SelectionTagView()
            view.configure(withTitle: title, isValid: isValid)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.delegate = self
            stackView.addArrangedSubview(view)
        }
    }

    private func setup() {
        addSubview(stackView)
        addSubview(collapsedView)

        let tagViewHeight: CGFloat = 30

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 44),

            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.heightAnchor.constraint(equalToConstant: tagViewHeight),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),

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
        if view === collapsedView {
            delegate?.selectionTagsContainerViewDidRemoveAllTags(self)
        } else if let index = stackView.arrangedSubviews.index(of: view) {
            delegate?.selectionTagsContainerView(self, didRemoveTagAt: index)
        }
    }
}

// MARK: - Private extensions

private extension Array where Element == String {
    var joinedTitles: String {
        let string = joined(separator: ", ")
        return count > 1 ? "(\(count)) \(string)" : string
    }
}
