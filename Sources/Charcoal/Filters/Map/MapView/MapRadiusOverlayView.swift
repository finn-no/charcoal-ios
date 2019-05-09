//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

final class MapRadiusOverlayView: UIView {
    var radius: CGFloat = 5 {
        didSet {
            widthConstraint.constant = radius * 2
            backgroundView.innerRadius = radius
        }
    }

    private lazy var backgroundView = BackgroundView(withAutoLayout: true)

    private lazy var centerPointView: UIView = {
        let view = UIView(withAutoLayout: true)
        view.backgroundColor = .primaryBlue
        return view
    }()

    private lazy var radiusView: UIView = {
        let view = UIView(withAutoLayout: true)
        view.backgroundColor = .clear
        view.layer.borderColor = .primaryBlue
        view.layer.borderWidth = 3
        return view
    }()

    private lazy var widthConstraint = radiusView.widthAnchor.constraint(equalToConstant: radius * 2)

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
        centerPointView.layer.cornerRadius = centerPointView.bounds.size.width / 2
        radiusView.layer.cornerRadius = radiusView.bounds.size.width / 2
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .clear
        clipsToBounds = true
        isUserInteractionEnabled = false

        addSubview(backgroundView)
        addSubview(radiusView)
        addSubview(centerPointView)

        backgroundView.fillInSuperview()

        NSLayoutConstraint.activate([
            radiusView.centerXAnchor.constraint(equalTo: centerXAnchor),
            radiusView.centerYAnchor.constraint(equalTo: centerYAnchor),
            radiusView.heightAnchor.constraint(equalTo: radiusView.widthAnchor),
            widthConstraint,

            centerPointView.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerPointView.centerYAnchor.constraint(equalTo: centerYAnchor),
            centerPointView.widthAnchor.constraint(equalToConstant: 6),
            centerPointView.heightAnchor.constraint(equalTo: centerPointView.widthAnchor),
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
        path.addArc(center: center, radius: innerRadius, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
        path.addRect(CGRect(origin: .zero, size: frame.size))

        maskLayer.path = path
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = UIColor.primaryBlue.withAlphaComponent(0.2)
        clipsToBounds = true
        isUserInteractionEnabled = false
        layer.mask = maskLayer
    }
}
