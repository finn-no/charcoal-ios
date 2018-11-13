//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class CollapsedSelectionValuesView: UIView, CurrentSelectionValuesContainer {
    var delegate: CurrentSelectionValuesContainerDelegate?

    private lazy var collapsedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .title5
        label.textColor = .milk
        return label
    }()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func configure(with selectedValues: [SelectionWithTitle]?) {
        guard let selectedValues = selectedValues else {
            collapsedLabel.text = nil
            return
        }
        let titles = selectedValues.compactMap({ $0.title })
        collapsedLabel.text = "(\(selectedValues.count)) " + titles.joined(separator: ", ")
    }

    private func setup() {
        layer.cornerRadius = 4
        backgroundColor = .primaryBlue

        addSubview(collapsedLabel)

        NSLayoutConstraint.activate([
            collapsedLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            collapsedLabel.heightAnchor.constraint(equalTo: heightAnchor),
            collapsedLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.mediumSpacing),
            collapsedLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumSpacing),
        ])
    }
}

class ExpandedSelectionValuesView: UIView, CurrentSelectionValuesContainer {
    var delegate: CurrentSelectionValuesContainerDelegate?

    private lazy var buttonContainerView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = .smallSpacing
        stackView.backgroundColor = .clear
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        return stackView
    }()

    private var selectedValues: [SelectionWithTitle]?

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        addSubview(buttonContainerView)

        buttonContainerView.fillInSuperview()
    }

    @objc private func didTapRemoveButton(_ sender: UIButton) {
        guard let tappedIndex = buttonContainerView.arrangedSubviews.index(of: sender) else {
            return
        }
        guard let selection = selectedValues?[safe: tappedIndex] else {
            return
        }
        delegate?.currentSelectionValuesContainerView(self, didTapRemoveSelection: selection)
    }

    func configure(with selectedValues: [SelectionWithTitle]?) {
        buttonContainerView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        self.selectedValues = selectedValues

        guard let selectedValues = selectedValues else {
            return
        }

        selectedValues.forEach { selectedValue in
            let button = RemoveFilterValueButton(title: selectedValue.title)
            button.translatesAutoresizingMaskIntoConstraints = false
            buttonContainerView.addArrangedSubview(button)
            button.addTarget(self, action: #selector(didTapRemoveButton(_:)), for: .touchUpInside)
        }
    }

    private class RemoveFilterValueButton: UIButton {
        init(title: String) {
            super.init(frame: .zero)
            setup(title: title)
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setup(title: "")
        }

        private func setup(title: String) {
            layer.cornerRadius = 4
            backgroundColor = .primaryBlue
            titleLabel?.font = .title5
            setTitleColor(.milk, for: .normal)
            contentEdgeInsets = UIEdgeInsets(leading: .mediumSpacing, trailing: .mediumSpacing)
            imageEdgeInsets = UIEdgeInsets(leading: .smallSpacing)
            setImage(UIImage(named: .removeFilterValue), for: .normal)
            setTitle(title, for: .normal)
        }

        override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
            var imageRect = super.imageRect(forContentRect: contentRect)
            imageRect.origin.x = contentRect.maxX - imageRect.width - imageEdgeInsets.right + imageEdgeInsets.left
            return imageRect
        }

        override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
            var titleRect = super.titleRect(forContentRect: contentRect)
            titleRect.origin.x = titleRect.minX - imageRect(forContentRect: contentRect).width
            return titleRect
        }
    }
}

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
