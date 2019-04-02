//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func filterViewController(_ viewController: FilterViewController, didSelectFilter filter: Filter)
    func filterViewControllerDidPressBottomButton(_ viewController: FilterViewController)
    func filterViewControllerWillBeginTextEditing(_ viewController: FilterViewController)
    func filterViewControllerWillEndTextEditing(_ viewController: FilterViewController)
}

class FilterViewController: UIViewController, FilterBottomButtonViewDelegate {

    // MARK: - Public properties

    weak var delegate: FilterViewControllerDelegate?
    let selectionStore: FilterSelectionStore
    private(set) var isShowingBottomButton = false

    // MARK: - Private properties

    lazy var bottomButtonBottomConstraint = bottomButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)

    private(set) lazy var bottomButton: FilterBottomButtonView = {
        let view = FilterBottomButtonView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    // MARK: - Init

    init(title: String, selectionStore: FilterSelectionStore) {
        self.selectionStore = selectionStore
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .milk
        setup()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.bringSubviewToFront(bottomButton)
    }

    // MARK: - Setup

    private func setup() {
        view.addSubview(bottomButton)

        NSLayoutConstraint.activate([
            bottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomButton.topAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
            bottomButton.heightAnchor.constraint(equalToConstant: bottomButton.height),
        ])
    }

    func showBottomButton(_ show: Bool, animated: Bool) {
        view.layoutIfNeeded()
        isShowingBottomButton = show
        bottomButtonBottomConstraint.isActive = show

        let duration = animated ? 0.3 : 0

        if show {
            bottomButton.isHidden = false
        }

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.bottomButton.isHidden = !show
        })
    }

    // MARK: - FilterBottomButtonViewDelegate

    func filterBottomButtonView(_ filterBottomButtonView: FilterBottomButtonView, didTapButton button: UIButton) {
        delegate?.filterViewControllerDidPressBottomButton(self)
    }
}
