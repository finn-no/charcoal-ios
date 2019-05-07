//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public class ScrollViewController: UIViewController, UIScrollViewDelegate {
    private lazy var topSeparatorView: UIView = {
        let view = UIView(withAutoLayout: true)
        view.backgroundColor = .white
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.7
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 3
        return view
    }()

    private(set) lazy var topSeparatorViewConstraint = topSeparatorView.topAnchor.constraint(equalTo: view.topAnchor)

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
            topSeparatorView.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

    // MARK: - Top separator

    private func showTopSeparator() {
        view.bringSubviewToFront(topSeparatorView)
        topSeparatorView.isHidden = false
    }

    private func hideTopSeparator() {
        topSeparatorView.isHidden = true
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.contentInset.top > 0 {
            showTopSeparator()
        } else {
            hideTopSeparator()
        }
    }
}
