//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public class FilterViewController: UIViewController {

    // MARK: - Public properties

    public weak var filterSelectionDelegate: FilterSelectionDelegate?

    // MARK: - Private properties

    lazy var applyButton: FilterBottomButtonView = {
        let buttonView = FilterBottomButtonView()
        buttonView.delegate = self
        buttonView.buttonTitle = "apply_button_title".localized()
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        return buttonView
    }()

    private lazy var applyButtonTopConstraint = applyButton.topAnchor.constraint(equalTo: view.bottomAnchor)
    private lazy var applyButtonBottomConstraint = applyButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)

    // MARK: - Setup

    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func showApplyButton(_ show: Bool, animated: Bool = true) {
        applyButtonTopConstraint.isActive = !show
        applyButtonBottomConstraint.isActive = show
        let duration = animated ? 0.3 : 0
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
}

extension FilterViewController: FilterBottomButtonViewDelegate {
    func filterBottomButtonView(_ filterBottomButtonView: FilterBottomButtonView, didTapButton button: UIButton) {
        filterSelectionDelegate?.filterViewControllerDidPressApplyButton(self)
    }
}

private extension FilterViewController {
    func setup() {
        view.backgroundColor = .milk
        view.addSubview(applyButton)
        NSLayoutConstraint.activate([
            applyButtonTopConstraint,
            applyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            applyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}
