//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

final class MapPolygonSquareSelectionOverlayView: UIView {
    var width: CGFloat = 180 {
        didSet {
            widthConstraint.constant = width
            backgroundView.innerRadius = width
        }
    }

    private lazy var backgroundView = BackgroundView(withAutoLayout: true)

    private lazy var squareView: UIView = {
        let view = UIView(withAutoLayout: true)
        view.backgroundColor = .clear
        view.layer.borderColor = .accentSecondaryBlue
        view.layer.borderWidth = 2
        return view
    }()

    private lazy var widthConstraint = squareView.widthAnchor.constraint(equalToConstant: width)

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
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .clear
        clipsToBounds = true
        isUserInteractionEnabled = false

        addSubview(backgroundView)
        addSubview(squareView)

        backgroundView.fillInSuperview()

        NSLayoutConstraint.activate([
            squareView.centerXAnchor.constraint(equalTo: centerXAnchor),
            squareView.centerYAnchor.constraint(equalTo: centerYAnchor),
            widthConstraint,
            squareView.heightAnchor.constraint(equalTo: squareView.widthAnchor),
        ])
    }
}

// MARK: - Private types

private final class BackgroundView: UIView {
    var innerRadius: CGFloat = 180 {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    private lazy var maskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.black.cgColor
        layer.fillRule = .evenOdd
        return layer
    }()

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

        let path = CGMutablePath()
        let origin = CGPoint(x: center.x - innerRadius / 2, y: center.y - innerRadius / 2)
        path.addRect(CGRect(origin: origin, size: CGSize(width: innerRadius, height: innerRadius)))

        maskLayer.path = path
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = UIColor.accentSecondaryBlue.withAlphaComponent(0.15)
        clipsToBounds = true
        isUserInteractionEnabled = false
        layer.mask = maskLayer
    }
}
