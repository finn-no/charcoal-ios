//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

final class InitialAreaSelectionOverlayView: UIView {
    var width: CGFloat = 180

    private lazy var squareView: UIView = {
        let view = UIView(withAutoLayout: true)
        view.backgroundColor = UIColor.accentSecondaryBlue.withAlphaComponent(0.15)
        view.layer.borderColor = .accentSecondaryBlue
        view.layer.borderWidth = 2
        return view
    }()

    private lazy var shadowView = AreaShadowView(withAutoLayout: true)

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
        addSubview(shadowView)

        NSLayoutConstraint.activate([
            squareView.centerXAnchor.constraint(equalTo: centerXAnchor),
            squareView.centerYAnchor.constraint(equalTo: centerYAnchor),
            squareView.widthAnchor.constraint(equalToConstant: width),
            squareView.heightAnchor.constraint(equalTo: squareView.widthAnchor),

            shadowView.centerXAnchor.constraint(equalTo: squareView.centerXAnchor),
            shadowView.centerYAnchor.constraint(equalTo: squareView.centerYAnchor),
            shadowView.widthAnchor.constraint(equalToConstant: width),
            shadowView.heightAnchor.constraint(equalTo: shadowView.widthAnchor),
        ])
    }
}

// MARK: - Private types

private final class AreaShadowView: UIView {
    private let offset = CGSize(width: 24, height: 24)
    private let radius: CGFloat = 30
    private let opacity: Float = 0.2
    private let color = UIColor.black

    public override func layoutSubviews() {
        super.layoutSubviews()

        let maskLayer = CAShapeLayer()
        let path = CGMutablePath()
        path.addPath(UIBezierPath(roundedRect: bounds.inset(by: UIEdgeInsets.zero), cornerRadius: 0).cgPath)
        path.addPath(UIBezierPath(roundedRect: bounds.inset(by: UIEdgeInsets(top: -offset.height - radius * 2, left: -offset.width - radius * 2, bottom: -offset.height - radius * 2, right: -offset.width - radius * 2)), cornerRadius: 0).cgPath)
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        maskLayer.fillRule = .evenOdd
        layer.mask = maskLayer

        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowColor = color.cgColor
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 0).cgPath
    }
}
