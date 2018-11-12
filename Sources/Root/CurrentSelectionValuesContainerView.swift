//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol CurrentSelectionValuesContainerViewDelegate: AnyObject {
    func currentSelectionValuesContainerView(_: CurrentSelectionValuesContainerView, didTapRemoveSelection: SelectionWithTitle)
}

class CurrentSelectionValuesContainerView: UIView {
    private let buttonHeight: CGFloat = 30

    private lazy var collapsedView: UIView = {
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.layer.cornerRadius = 4
        backgroundView.backgroundColor = .primaryBlue
        return backgroundView
    }()

    private lazy var collapsedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .title5
        label.textColor = .milk
        return label
    }()

    private lazy var expandedView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = .smallSpacing
        stackView.backgroundColor = .clear
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        return stackView
    }()

    var delegate: CurrentSelectionValuesContainerViewDelegate?

    var selectedValues: [SelectionWithTitle]? {
        didSet {
            var collapsedText = ""
            expandedView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            selectedValues?.forEach { selectedValue in
                if !collapsedText.isEmpty {
                    collapsedText += ", "
                }
                collapsedText += selectedValue.title
                let button = RemoveFilterValueButton(title: selectedValue.title)
                button.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([button.heightAnchor.constraint(equalToConstant: buttonHeight)])
                expandedView.addArrangedSubview(button)
                button.addTarget(self, action: #selector(didTapRemoveButton(_:)), for: .touchUpInside)
            }
            collapsedLabel.text = "(\(selectedValues?.count ?? 0)) " + collapsedText
        }
    }

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
        collapsedView.addSubview(collapsedLabel)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 44),

            expandedView.centerYAnchor.constraint(equalTo: centerYAnchor),
            expandedView.trailingAnchor.constraint(equalTo: trailingAnchor),

            collapsedView.centerYAnchor.constraint(equalTo: centerYAnchor),
            collapsedView.heightAnchor.constraint(equalToConstant: buttonHeight),
            collapsedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collapsedView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),

            collapsedLabel.centerYAnchor.constraint(equalTo: collapsedView.centerYAnchor),
            collapsedLabel.heightAnchor.constraint(equalToConstant: buttonHeight),
            collapsedLabel.trailingAnchor.constraint(equalTo: collapsedView.trailingAnchor, constant: -.mediumSpacing),
            collapsedLabel.leadingAnchor.constraint(equalTo: collapsedView.leadingAnchor, constant: .mediumSpacing),
        ])
    }

    @objc private func didTapRemoveButton(_ sender: UIButton) {
        guard let tappedIndex = expandedView.arrangedSubviews.index(of: sender) else {
            return
        }
        guard let selection = selectedValues?[safe: tappedIndex] else {
            return
        }
        delegate?.currentSelectionValuesContainerView(self, didTapRemoveSelection: selection)
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
