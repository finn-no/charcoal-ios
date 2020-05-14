//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

protocol CalloutOverlayDelegate: AnyObject {
    func calloutOverlayDidTapInside(_ view: CalloutOverlay)
}

final class CalloutOverlay: UIView {
    weak var delegate: CalloutOverlayDelegate?

    // MARK: - Private properties

    private let direction: CalloutView.Direction
    private let arrowAlignment: CalloutView.ArrowAlignment

    private var calloutViewDirectionalAnchor: NSLayoutYAxisAnchor {
        switch direction {
        case .up:
            return calloutView.topAnchor
        case .down:
            return calloutView.bottomAnchor
        }
    }

    private var directionalConstraints: [NSLayoutConstraint]?

    private lazy var calloutView: CalloutView = {
        let view = CalloutView(direction: direction, arrowAlignment: arrowAlignment)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var bodyView: UIView = {
        let view = UIView(withAutoLayout: true)
        if #available(iOS 13, *),
            traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = UIColor.bgSecondary.withAlphaComponent(0.6)
        } else {
            view.backgroundColor = UIColor(white: 1, alpha: 0.8)
        }
        return view
    }()

    // MARK: - Init

    init(direction: CalloutView.Direction, arrowAlignment: CalloutView.ArrowAlignment = .center) {
        self.direction = direction
        self.arrowAlignment = arrowAlignment
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    func configure(withText text: String, calloutAnchor: NSLayoutYAxisAnchor) {
        calloutView.show(withText: text)
        calloutViewDirectionalAnchor.constraint(equalTo: calloutAnchor).isActive = true
        switch direction {
        case .up:
            directionalConstraints = [
                bodyView.topAnchor.constraint(equalTo: calloutView.topAnchor),
                bodyView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ]
        case .down:
            directionalConstraints = [
                bodyView.topAnchor.constraint(equalTo: topAnchor),
                bodyView.bottomAnchor.constraint(equalTo: calloutView.bottomAnchor),
            ]
        }
    }

    func configure(withText text: String, calloutTopAnchor: NSLayoutYAxisAnchor) {
        calloutView.show(withText: text)
        calloutView.topAnchor.constraint(equalTo: calloutTopAnchor).isActive = true
        directionalConstraints = nil
    }

    private func setup() {
        backgroundColor = .clear

        addSubview(bodyView)
        addSubview(calloutView)

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(gestureRecognizer)

        var constraints = [
            calloutView.widthAnchor.constraint(equalToConstant: 250),

            bodyView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bodyView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ]

        switch arrowAlignment {
        case .center:
            constraints.append(calloutView.centerXAnchor.constraint(equalTo: centerXAnchor))
        case .left:
            constraints.append(calloutView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .spacingM))
        case .right:
            constraints.append(calloutView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.spacingM))
        }

        if let directionalConstraints = directionalConstraints {
            constraints += directionalConstraints
        } else {
            constraints += [
                bodyView.topAnchor.constraint(equalTo: topAnchor),
                bodyView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ]
        }

        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Actions

    @objc private func handleTap() {
        delegate?.calloutOverlayDidTapInside(self)
    }
}
