//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

final class MapRadiusView: UIView {
    var radius: CGFloat = 5 {
        didSet {
            widthConstraint.constant = radius * 2
        }
    }

    private lazy var centerPointView: UIView = {
        let view = UIView(withAutoLayout: true)
        view.backgroundColor = .milk
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var widthConstraint = widthAnchor.constraint(equalToConstant: radius * 2)

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.width / 2.0
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = UIColor.primaryBlue.withAlphaComponent(0.2)
        isUserInteractionEnabled = false

        layer.borderColor = .primaryBlue
        layer.borderWidth = 3

        addSubview(centerPointView)

        NSLayoutConstraint.activate([
            widthConstraint,
            heightAnchor.constraint(equalTo: widthAnchor),

            centerPointView.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerPointView.centerYAnchor.constraint(equalTo: centerYAnchor),
            centerPointView.widthAnchor.constraint(equalToConstant: 6),
            centerPointView.heightAnchor.constraint(equalTo: centerPointView.widthAnchor)
        ])
    }
}
