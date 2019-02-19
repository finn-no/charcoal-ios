//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol FilterViewControllerDelegate: class {
    func filterViewControllerDidSelectApply(_ viewController: FilterViewController)
    func filterViewController(_ viewController: FilterViewController, didSelectFilter filter: Filter)
}

class FilterViewController: UIViewController, FilterViewControllerDelegate, FilterBottomButtonViewDelegate {

    // MARK: - Public properties

    var filter: Filter
    let selectionStore: FilterSelectionStore
    var isShowingBottomButton = false
    weak var delegate: FilterViewControllerDelegate?

    // MARK: - Private properties

    lazy var bottomButtonBottomConstraint = bottomButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)

    lazy var bottomButton: FilterBottomButtonView = {
        let view = FilterBottomButtonView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Setup

    init(filter: Filter, selectionStore: FilterSelectionStore) {
        self.filter = filter
        self.selectionStore = selectionStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .milk
        navigationItem.title = filter.title
        setup()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.bringSubviewToFront(bottomButton)
    }

    func showBottomButton(_ show: Bool, animated: Bool) {
        view.layoutIfNeeded()
        isShowingBottomButton = show
        bottomButtonBottomConstraint.isActive = show
        let duration = animated ? 0.3 : 0
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }

    func filterViewControllerDidSelectApply(_ viewController: FilterViewController) {
        delegate?.filterViewControllerDidSelectApply(viewController)
    }

    func filterViewController(_ viewController: FilterViewController, didSelectFilter filter: Filter) {
        delegate?.filterViewController(viewController, didSelectFilter: filter)
    }

    // MARK: - FilterBottomButtonViewDelegate

    func filterBottomButtonView(_ filterBottomButtonView: FilterBottomButtonView, didTapButton button: UIButton) {
        delegate?.filterViewControllerDidSelectApply(self)
    }
}

private extension FilterViewController {
    func setup() {
        view.addSubview(bottomButton)
        NSLayoutConstraint.activate([
            bottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomButton.topAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
            bottomButton.heightAnchor.constraint(equalToConstant: bottomButton.height),
        ])
    }
}
