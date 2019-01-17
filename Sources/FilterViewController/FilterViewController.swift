//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol ApplySelectionButtonOwner: class {
    var isShowingApplyButton: Bool { get }
    func showApplyButton(_ show: Bool, animated: Bool)
}

public class FilterViewController: UIViewController, ApplySelectionButtonOwner {

    // MARK: - Public properties

    public let selectionDataSource: FilterSelectionDataSource
    public let dataSource: FilterDataSource
    public var navigator: FilterNavigator?

    public var isShowingApplyButton: Bool = false
    public weak var parentApplyButtonOwner: ApplySelectionButtonOwner?

    lazy var applySelectionButton: FilterBottomButtonView = {
        let buttonView = FilterBottomButtonView()
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.delegate = self
        buttonView.buttonTitle = "apply_button_title".localized()
        return buttonView
    }()

    // MARK: - Private properties

    private lazy var applyButtonTopAnchorConstraint = applySelectionButton.topAnchor.constraint(equalTo: view.bottomAnchor)

    // MARK: - Setup

    init(dataSource: FilterDataSource, selectionDataSource: FilterSelectionDataSource, navigator: FilterNavigator?) {
        self.dataSource = dataSource
        self.selectionDataSource = selectionDataSource
        self.navigator = navigator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .milk
        setupApplyButton()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.bringSubviewToFront(applySelectionButton)
    }

    public func showApplyButton(_ show: Bool, animated: Bool = true) {
        isShowingApplyButton = show
        applyButtonTopAnchorConstraint.isActive = !show
        let duration = animated ? 0.3 : 0
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        parentApplyButtonOwner?.showApplyButton(show, animated: false)
    }
}

extension FilterViewController: FilterBottomButtonViewDelegate {
    func filterBottomButtonView(_ filterBottomButtonView: FilterBottomButtonView, didTapButton button: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
}

private extension FilterViewController {
    func setupApplyButton() {
        view.addSubview(applySelectionButton)
        NSLayoutConstraint.activate([
            applyButtonTopAnchorConstraint,
            applySelectionButton.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor),
            applySelectionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            applySelectionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}
