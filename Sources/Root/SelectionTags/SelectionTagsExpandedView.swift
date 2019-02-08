//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

final class SelectionTagsExpandedView: UIView, CurrentSelectionValuesContainer {
    var delegate: CurrentSelectionValuesContainerDelegate?
    private var selectedValues: [SelectionWithTitle]?

    private lazy var buttonContainerView: UIStackView = {
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

    // MARK: - Init

    private func setup() {
        backgroundColor = .clear
        addSubview(buttonContainerView)
        buttonContainerView.fillInSuperview()
    }

    func configure(with selectedValues: [SelectionWithTitle]?) {
        buttonContainerView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        self.selectedValues = selectedValues

        guard let selectedValues = selectedValues else {
            return
        }

        selectedValues.forEach { selectedValue in
            let view = FilterTagView(title: selectedValue.title)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = selectedValue.selectionInfo.isValid ? .primaryBlue : .cherry
            view.delegate = self
            buttonContainerView.addArrangedSubview(view)
        }
    }
}

// MARK: - FilterTagViewDelegate

extension SelectionTagsExpandedView: FilterTagViewDelegate {
    func filterTagViewDidSelectRemove(_ view: FilterTagView) {
        guard let tappedIndex = buttonContainerView.arrangedSubviews.index(of: view) else {
            return
        }
        guard let selection = selectedValues?[safe: tappedIndex] else {
            return
        }
        delegate?.currentSelectionValuesContainerView(self, didTapRemoveSelection: selection)
    }
}
