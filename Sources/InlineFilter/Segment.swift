//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class Segment: UIControl {
    var selectedItems: [Int] = []

    private let titles: [String]
    private var arrangedSubviews: [UIView] = []

    public init(titles: [String]) {
        self.titles = titles
        super.init(frame: .zero)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        for (i, view) in arrangedSubviews.enumerated() {
            border(for: view, atIndex: i, lineWidth: 4, strokeColor: .silver)
        }
    }
}

private extension Segment {
    func setup() {
        var previousLeadingAnchor = leadingAnchor
        for title in titles {
            let button = UIButton(type: .custom)
            button.titleLabel?.font = .regularBody
            button.setTitle(title, for: .normal)
            button.setTitleColor(.spaceGray, for: .normal)
            button.setTitleColor(.milk, for: .selected)
            button.addTarget(self, action: #selector(handleButton(sender:)), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            addSubview(button)
            arrangedSubviews.append(button)
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: topAnchor),
                button.leadingAnchor.constraint(equalTo: previousLeadingAnchor),
                button.heightAnchor.constraint(equalTo: heightAnchor),
                button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / CGFloat(titles.count)),
            ])
            previousLeadingAnchor = button.trailingAnchor
        }
    }

    func border(for view: UIView, atIndex index: Int, lineWidth: CGFloat, strokeColor: CGColor) {
        var radius = 16 as CGFloat
        let width = view.frame.width
        let height = view.frame.height

        var corners: UIRectCorner = [.topRight]

        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        view.layer.mask = maskLayer

        let path = CGMutablePath()
        // Top border line
        var point = corners.contains(.topLeft) ? CGPoint(x: radius, y: 0) : .zero
        path.move(to: point)
        var r = corners.contains(.topRight) ? radius : 0
        line(length: width - r, radius: r, transform: .identity, path: path)

//        path.addLine(to: CGPoint(x: view.bounds.width, y: height))
//        path.addLine(to: CGPoint(x: 0, y: height))
//        path.addLine(to: CGPoint(x: 0, y: 0))

        let borderLayer = CAShapeLayer()
        borderLayer.frame = view.bounds
        borderLayer.path = path
        borderLayer.lineWidth = lineWidth
        borderLayer.strokeColor = .licorice // strokeColor
        borderLayer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(borderLayer)
    }

    func line(length: CGFloat, radius: CGFloat, transform: CGAffineTransform, path: CGMutablePath) {
        path.addLine(to: CGPoint(x: length - radius, y: 0), transform: transform)
        if radius != 0 {
            path.addArc(center: CGPoint(x: length, y: radius), radius: radius, startAngle: 3 * .pi / 2, endAngle: 4 * .pi / 2, clockwise: false, transform: transform)
        }
    }

    @objc func handleButton(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.backgroundColor = sender.isSelected ? .primaryBlue : .milk
        guard let index = arrangedSubviews.firstIndex(of: sender) else { return }
        border(for: sender, atIndex: index, lineWidth: 2, strokeColor: sender.isSelected ? .primaryBlue : .silver)
    }
}
