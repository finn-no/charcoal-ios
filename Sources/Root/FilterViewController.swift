//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public class FilterViewController: UIViewController {
    public weak var filterSelectionDelegate: FilterSelectionDelegate?

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var applyButton: FilterBottomButtonView = {
        let buttonView = FilterBottomButtonView()
        buttonView.buttonTitle = "apply_button_title".localized()
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        return buttonView
    }()

    func presentApplyButton() {
    }
}

private extension FilterViewController {
    func setup() {
        view.addSubview(applyButton)
        NSLayoutConstraint.activate([
            applyButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            applyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            applyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            applyButton.button.bottomAnchor.constraint(equalTo: safeBottomAnchor),
        ])
    }
}
