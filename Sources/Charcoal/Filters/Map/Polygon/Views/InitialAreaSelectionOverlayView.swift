//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit
import Warp

final class InitialAreaSelectionOverlayView: UIView {
    var width: CGFloat = 180

    private lazy var squareView: UIView = {
        let view = UIView(withAutoLayout: true)
        let color: UIColor = Warp.UIToken.borderSecondary
        view.backgroundColor = color.withAlphaComponent(0.15)
        view.layer.borderColor = color.cgColor
        view.layer.borderWidth = 2
        return view
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .clear
        isUserInteractionEnabled = false

        addSubview(squareView)

        NSLayoutConstraint.activate([
            squareView.centerXAnchor.constraint(equalTo: centerXAnchor),
            squareView.centerYAnchor.constraint(equalTo: centerYAnchor),
            squareView.widthAnchor.constraint(equalToConstant: width),
            squareView.heightAnchor.constraint(equalTo: squareView.widthAnchor),
        ])
    }
}
