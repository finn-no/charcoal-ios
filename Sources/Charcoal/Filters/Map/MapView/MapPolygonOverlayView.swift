//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

final class MapPolygonOverlayView: UIView {
    var radius: CGFloat = 5 {
        didSet {
            widthConstraint.constant = radius * 2
            backgroundView.innerRadius = radius
        }
    }

    private lazy var backgroundView = BackgroundView(withAutoLayout: true)

    private lazy var radiusView: UIView = {
        let view = UIView(withAutoLayout: true)
        view.backgroundColor = .clear
        view.layer.borderColor = .btnPrimary
        view.layer.borderWidth = 3
        return view
    }()

    private lazy var widthConstraint = radiusView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6)

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
        addSubview(radiusView)

        backgroundView.fillInSuperview()

        NSLayoutConstraint.activate([
            radiusView.centerXAnchor.constraint(equalTo: centerXAnchor),
            radiusView.centerYAnchor.constraint(equalTo: centerYAnchor),
            radiusView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6),
            radiusView.heightAnchor.constraint(equalTo: radiusView.widthAnchor),
        ])
    }
}

// MARK: - Private types

private final class BackgroundView: UIView {
    var innerRadius: CGFloat = 5 {
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
        let origin = CGPoint(x: center.x - innerRadius/2, y: center.y - innerRadius/2)
        path.addRect(CGRect(origin: origin, size: CGSize(width: innerRadius, height: innerRadius)))

        maskLayer.path = path
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = UIColor.btnPrimary.withAlphaComponent(0.1)
        clipsToBounds = true
        isUserInteractionEnabled = false
        layer.mask = maskLayer
    }
}
