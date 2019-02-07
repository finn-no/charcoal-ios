//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

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
            let button = FilterValueView(title: selectedValue.title)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.backgroundColor = selectedValue.selectionInfo.isValid ? .primaryBlue : .cherry
            buttonContainerView.addArrangedSubview(button)
            // button.addTarget(self, action: #selector(didTapRemoveButton(_:)), for: .touchUpInside)
        }
    }
}

private class FilterValueView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel(withAutoLayout: true)
        label.font = .title5
        label.textColor = .milk
        return label
    }()

    private lazy var button: UIButton = {
        let button = UIButton(withAutoLayout: true)
        button.imageEdgeInsets = UIEdgeInsets(leading: .smallSpacing)
        button.setImage(UIImage(named: .removeFilterValue), for: .normal)
        // button.addTarget(self, action: #selector(didTapRemoveButton(_:)), for: .touchUpInside)
        return button
    }()

    init(title: String) {
        super.init(frame: .zero)
        setup(title: title)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup(title: "")
    }

    private func setup(title: String) {
        addSubview(titleLabel)
        addSubview(button)

        titleLabel.text = title

        layer.cornerRadius = 4
        backgroundColor = .primaryBlue

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: .mediumSpacing),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.mediumSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumSpacing),

            button.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
        ])
    }
}
