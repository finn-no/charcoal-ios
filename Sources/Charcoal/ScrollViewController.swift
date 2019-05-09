//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public class ScrollViewController: UIViewController, UIScrollViewDelegate {
    // MARK: - Internal properties

    weak var scrollView: UIScrollView?

    var topSeperatorViewHeight: CGFloat = 0 {
        didSet {
            topSeparatorViewConstraint.constant = topSeperatorViewHeight
        }
    }

    let shadowOpacity: Float = 0.3
    let shadowRadius: CGFloat = 3
    let shadowScrollFactor: CGFloat = 0.2

    // MARK: - Private properties

    private lazy var topSeparatorView: UIView = {
        let view = UIView(withAutoLayout: true)
        view.backgroundColor = .white
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = shadowOpacity
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = shadowRadius
        return view
    }()

    private lazy var topSeparatorViewConstraint = topSeparatorView.bottomAnchor.constraint(equalTo: view.topAnchor)

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        hideTopSeparator()
    }

    // MARK: - Setup

    private func setup() {
        view.addSubview(topSeparatorView)

        NSLayoutConstraint.activate([
            topSeparatorViewConstraint,
            topSeparatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topSeparatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topSeparatorView.topAnchor.constraint(equalTo: view.topAnchor, constant: -44),
        ])
    }

    // MARK: - Top separator

    private func showTopSeparator(withShadowRadius radius: CGFloat) {
        view.bringSubviewToFront(topSeparatorView)
        topSeparatorView.isHidden = false
        topSeparatorView.layer.shadowRadius = radius
    }

    private func hideTopSeparator() {
        topSeparatorView.isHidden = true
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let overlap = scrollView.contentOffset.y + scrollView.contentInset.top
        if overlap > 0 {
            showTopSeparator(withShadowRadius: min(overlap * shadowScrollFactor, shadowRadius))
        } else {
            hideTopSeparator()
        }
    }
}
