//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

extension SegmentButton {
    enum Position {
        case first, middle, last
    }
}

class SegmentButton: UIButton {
    static let borderColor: UIColor = .silver
    static let borderWidth = 2 as CGFloat

    var position: Position = .middle

    override var isSelected: Bool {
        didSet {
            setupForSelected(isSelected)
        }
    }

    private var borderLayer: CAShapeLayer?
    private let selectedBackgroundColor: UIColor = .primaryBlue

    init(title: String) {
        super.init(frame: .zero)
        titleLabel?.font = .regularBody
        setTitle(title, for: .normal)
        setTitleColor(.spaceGray, for: .normal)
        setTitleColor(.milk, for: .selected)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupBorder()
    }
}

private extension SegmentButton {
    func setupForSelected(_ selected: Bool) {
        backgroundColor = selected ? selectedBackgroundColor : .milk
        guard let borderLayer = borderLayer else { return }
        if selected {
            borderLayer.removeFromSuperlayer()
        } else {
            layer.addSublayer(borderLayer)
        }
    }

    func setupBorder() {
        guard self.borderLayer == nil else {
            return
        }

        let borderPath: CGPath
        let maskPath: CGPath
        let radius: CGFloat

        switch position {
        case .first:
            radius = frame.height / 2
            maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.bottomLeft, .topLeft], cornerRadii: CGSize(width: radius, height: radius)).cgPath
            borderPath = path(with: CGSize(width: frame.width - radius, height: frame.height),
                              roundedEdge: true,
                              transform: CGAffineTransform.identity.translatedBy(x: frame.width, y: frame.height).rotated(by: .pi))

        case .middle:
            radius = 0
            maskPath = UIBezierPath(rect: bounds).cgPath
            borderPath = path(with: CGSize(width: frame.width, height: frame.height))

        case .last:
            radius = frame.height / 2
            maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.bottomRight, .topRight], cornerRadii: CGSize(width: radius, height: radius)).cgPath
            borderPath = path(with: CGSize(width: frame.width - radius, height: frame.height),
                              roundedEdge: true)
        }

        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath
        layer.mask = maskLayer

        let borderLayer = CAShapeLayer()
        borderLayer.frame = bounds
        borderLayer.path = borderPath
        borderLayer.lineWidth = SegmentButton.borderWidth
        borderLayer.strokeColor = SegmentButton.borderColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(borderLayer)
        self.borderLayer = borderLayer
    }

    func path(with size: CGSize, roundedEdge: Bool = false, transform: CGAffineTransform = .identity) -> CGPath {
        let lineWidth = SegmentButton.borderWidth
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: lineWidth / 2), transform: transform)
        path.addLine(to: CGPoint(x: size.width, y: lineWidth / 2), transform: transform)
        if roundedEdge {
            path.addArc(center: CGPoint(x: size.width, y: size.height / 2), radius: (size.height - lineWidth) / 2, startAngle: 3 * .pi / 2, endAngle: 5 * .pi / 2, clockwise: false, transform: transform)
        } else {
            path.move(to: CGPoint(x: size.width, y: size.height - lineWidth / 2), transform: transform)
        }
        path.addLine(to: CGPoint(x: 0, y: size.height - lineWidth / 2), transform: transform)
        return path
    }
}
