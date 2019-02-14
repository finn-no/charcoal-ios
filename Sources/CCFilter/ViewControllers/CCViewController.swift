//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol CCViewControllerDelegate: class {
    func viewControllerDidPressBottomButton(_ viewController: CCViewController)
    func viewController(_ viewController: CCViewController, didSelect filterNode: CCFilterNode)
}

class CCViewController: UIViewController, CCViewControllerDelegate, FilterBottomButtonViewDelegate {

    // MARK: - Public properties

    let filterNode: CCFilterNode
    let selectionStore: FilterSelectionStore
    var isShowingBottomButton = false
    weak var delegate: CCViewControllerDelegate?

    // MARK: - Private properties

    lazy var bottomButtonBottomConstraint = bottomButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)

    lazy var bottomButton: FilterBottomButtonView = {
        let view = FilterBottomButtonView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Setup

    init(filterNode: CCFilterNode, selectionStore: FilterSelectionStore) {
        self.filterNode = filterNode
        self.selectionStore = selectionStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .milk
        navigationItem.title = filterNode.title
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

    func viewControllerDidPressBottomButton(_ viewController: CCViewController) {
        delegate?.viewControllerDidPressBottomButton(viewController)
    }

    func viewController(_ viewController: CCViewController, didSelect filterNode: CCFilterNode) {
        delegate?.viewController(viewController, didSelect: filterNode)
    }

    // MARK: - FilterBottomButtonViewDelegate

    func filterBottomButtonView(_ filterBottomButtonView: FilterBottomButtonView, didTapButton button: UIButton) {
        delegate?.viewControllerDidPressBottomButton(self)
    }
}

private extension CCViewController {
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
