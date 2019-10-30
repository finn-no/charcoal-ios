//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

extension SegmentButton {
    enum BorderStyle {
        case first, middle, last, single
    }
}

protocol SegmentButtonDelegate: AnyObject {
    func segmentButtonDidFocusOnAccessibilityElement(_ segment: SegmentButton)
}

final class SegmentButton: UIButton {
    static let borderColor: UIColor = .silver
    static let borderWidth: CGFloat = 1.5

    weak var delegate: SegmentButtonDelegate?
    var borderStyle: BorderStyle = .middle

    override var isSelected: Bool {
        didSet {
            updateSelected(isSelected)
        }
    }

    private var borderLayer = CAShapeLayer()
    private var maskLayer = CAShapeLayer()
    private var selectedBackgroundColor: UIColor = .primaryBlue

    init(title: String) {
        super.init(frame: .zero)
        setup(with: title)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        drawBorder()
    }

    override func accessibilityElementDidBecomeFocused() {
        super.accessibilityElementDidBecomeFocused()
        delegate?.segmentButtonDidFocusOnAccessibilityElement(self)
    }
}

private extension SegmentButton {
    func setup(with title: String) {
        titleLabel?.font = .bodyRegular
        titleLabel?.adjustsFontForContentSizeCategory = true

        setTitle(title, for: .normal)
        setTitleColor(.licorice, for: .normal)
        setTitleColor(.milk, for: .selected)
        backgroundColor = .bgPrimary
        contentEdgeInsets = UIEdgeInsets(top: 0, leading: .mediumLargeSpacing, bottom: 0, trailing: .mediumLargeSpacing)

        borderLayer.lineWidth = SegmentButton.borderWidth
        borderLayer.strokeColor = SegmentButton.borderColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(borderLayer)
        layer.mask = maskLayer
    }

    func updateSelected(_ selected: Bool) {
        backgroundColor = selected ? selectedBackgroundColor : .milk

        if selected {
            borderLayer.removeFromSuperlayer()
        } else {
            layer.addSublayer(borderLayer)
        }
    }

    func drawBorder() {
        let borderPath: CGPath
        let maskPath: CGPath
        let radius: CGFloat

        switch borderStyle {
        case .first:
            radius = frame.height / 2
            maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: [.bottomLeft, .topLeft],
                                    cornerRadii: CGSize(width: radius, height: radius)).cgPath
            borderPath = path(with: CGSize(width: frame.width - radius, height: frame.height),
                              roundedEdge: true,
                              transform: CGAffineTransform.identity.translatedBy(x: frame.width, y: frame.height).rotated(by: .pi))

        case .middle:
            radius = 0
            maskPath = UIBezierPath(rect: bounds).cgPath
            borderPath = path(with: CGSize(width: frame.width, height: frame.height))

        case .last:
            radius = frame.height / 2
            maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: [.bottomRight, .topRight],
                                    cornerRadii: CGSize(width: radius, height: radius)).cgPath
            borderPath = path(with: CGSize(width: frame.width - radius, height: frame.height),
                              roundedEdge: true)
        case .single:
            radius = frame.height / 2
            maskPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
            let borderWidth = SegmentButton.borderWidth
            borderPath = UIBezierPath(roundedRect: CGRect(x: borderWidth / 2, y: borderWidth / 2, width: bounds.width - borderWidth, height: bounds.height - borderWidth),
                                      cornerRadius: radius - borderWidth / 2).cgPath
        }

        maskLayer.path = maskPath
        borderLayer.path = borderPath
    }

    func path(with size: CGSize, roundedEdge: Bool = false, transform: CGAffineTransform = .identity) -> CGPath {
        let lineWidth = SegmentButton.borderWidth
        let path = CGMutablePath()
        // Need to use lineWidth / 2 because path is draw in the center of the line
        path.move(to: CGPoint(x: 0, y: lineWidth / 2), transform: transform)
        path.addLine(to: CGPoint(x: size.width, y: lineWidth / 2), transform: transform)
        if roundedEdge {
            path.addArc(center: CGPoint(x: size.width, y: size.height / 2),
                        radius: (size.height - lineWidth) / 2,
                        startAngle: 3 * .pi / 2,
                        endAngle: 5 * .pi / 2,
                        clockwise: false,
                        transform: transform)
        } else {
            path.move(to: CGPoint(x: size.width, y: size.height - lineWidth / 2), transform: transform)
        }
        path.addLine(to: CGPoint(x: 0, y: size.height - lineWidth / 2), transform: transform)
        return path
    }
}
