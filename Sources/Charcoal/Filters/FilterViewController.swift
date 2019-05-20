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

class FilterViewController: ScrollViewController, FilterBottomButtonViewDelegate {
    weak var delegate: FilterViewControllerDelegate?
    let selectionStore: FilterSelectionStore

    // MARK: - Private properties

    lazy var bottomButtonBottomConstraint = bottomButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)

    private(set) lazy var bottomButton: FilterBottomButtonView = {
        let view = FilterBottomButtonView()
        view.delegate = self
        view.isHidden = true
        return view
    }()

    private(set) var isShowingBottomButton = false

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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .milk
        setup()

        let gestureRecognizer = UIScreenEdgePanGestureRecognizer()
        gestureRecognizer.delegate = self
        gestureRecognizer.edges = .left
        view.addGestureRecognizer(gestureRecognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enableSwipeBack(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        enableSwipeBack(true)
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        bottomButton.update(with: scrollView)
    }

    // MARK: - Internal functions

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

    func enableSwipeBack(_ isEnabled: Bool) {
        let gestureRecognizer = navigationController?.interactivePopGestureRecognizer

        if gestureRecognizer?.isEnabled != isEnabled {
            gestureRecognizer?.isEnabled = isEnabled
        }
    }

    // MARK: - Setup

    private func setup() {
        view.insertSubview(bottomButton, belowSubview: topShadowView)

        NSLayoutConstraint.activate([
            bottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomButton.topAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),

            topShadowView.bottomAnchor.constraint(equalTo: view.topAnchor),
        ])
    }

    // MARK: - FilterBottomButtonViewDelegate

    func filterBottomButtonView(_ filterBottomButtonView: FilterBottomButtonView, didTapButton button: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        delegate?.filterViewControllerDidPressBottomButton(self)
    }
}

extension FilterViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        enableSwipeBack(!(touch.view is UISlider))
        return false
    }
}
