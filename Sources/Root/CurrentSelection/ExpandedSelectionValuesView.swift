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
            let button = RemoveFilterValueButton(title: selectedValue.title)
            button.translatesAutoresizingMaskIntoConstraints = false
            buttonContainerView.addArrangedSubview(button)
            button.addTarget(self, action: #selector(didTapRemoveButton(_:)), for: .touchUpInside)
        }
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
