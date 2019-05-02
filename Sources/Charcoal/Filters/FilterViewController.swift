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

    private lazy var topSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.layer.shadowRadius = 3
        return view
    }()

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
        hideTopSeparator()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.bringSubviewToFront(bottomButton)
    }

    // MARK: - Setup

    private func setup() {
        view.addSubview(topSeparatorView)
        view.addSubview(bottomButton)

        NSLayoutConstraint.activate([
            topSeparatorView.topAnchor.constraint(equalTo: view.topAnchor),
            topSeparatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topSeparatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topSeparatorView.heightAnchor.constraint(equalToConstant: 1),

            bottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomButton.topAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
        ])
    }

    func showTopSeparator() {
        view.bringSubviewToFront(topSeparatorView)
        topSeparatorView.isHidden = false
    }

    func hideTopSeparator() {
        topSeparatorView.isHidden = true
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
