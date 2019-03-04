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

    private lazy var multiTagView: SelectionTagView = {
        let view = SelectionTagView(withAutoLayout: true)
        view.delegate = self
        return view
    }()

    private lazy var tagsStackView: UIStackView = {
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
        tagsStackView.layoutIfNeeded()

        let showCollapsedView = frame.width < tagsStackView.frame.width
        tagsStackView.isHidden = showCollapsedView
        multiTagView.isHidden = !showCollapsedView

        super.layoutSubviews()
    }

    // MARK: - Setup

    func configure(with selectionTitles: [String], isValid: Bool) {
        multiTagView.configure(withTitle: selectionTitles.joinedTitles, isValid: isValid)
        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        selectionTitles.forEach { title in
            let view = SelectionTagView()
            view.configure(withTitle: title, isValid: isValid)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.delegate = self
            tagsStackView.addArrangedSubview(view)
        }
    }

    private func setup() {
        addSubview(tagsStackView)
        addSubview(multiTagView)

        let tagViewHeight: CGFloat = 30

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 44),

            tagsStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            tagsStackView.heightAnchor.constraint(equalToConstant: tagViewHeight),
            tagsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),

            multiTagView.centerYAnchor.constraint(equalTo: centerYAnchor),
            multiTagView.heightAnchor.constraint(equalToConstant: tagViewHeight),
            multiTagView.trailingAnchor.constraint(equalTo: trailingAnchor),
            multiTagView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
        ])
    }
}

// MARK: - FilterTagViewDelegate

extension SelectionTagsContainerView: SelectionTagViewDelegate {
    func selectionTagViewDidSelectRemove(_ view: SelectionTagView) {
        if view === multiTagView {
            delegate?.selectionTagsContainerViewDidRemoveAllTags(self)
        } else if let index = tagsStackView.arrangedSubviews.index(of: view) {
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
