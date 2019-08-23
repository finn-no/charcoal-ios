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

    private var calloutViewDirectionalAnchor: NSLayoutYAxisAnchor {
        switch direction {
        case .up:
            return calloutView.topAnchor
        case .down:
            return calloutView.bottomAnchor
        }
    }

    private var directionalConstraints: [NSLayoutConstraint] {
        switch direction {
        case .up:
            return [
                bodyView.topAnchor.constraint(equalTo: calloutView.topAnchor),
                bodyView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ]
        case .down:
            return [
                bodyView.topAnchor.constraint(equalTo: topAnchor),
                bodyView.bottomAnchor.constraint(equalTo: calloutView.bottomAnchor),
            ]
        }
    }

    private lazy var calloutView: CalloutView = {
        let view = CalloutView(direction: direction)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var bodyView: UIView = {
        let view = UIView(withAutoLayout: true)
        view.backgroundColor = UIColor(white: 1, alpha: 0.8)
        return view
    }()

    // MARK: - Init

    init(direction: CalloutView.Direction) {
        self.direction = direction
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
    }

    private func setup() {
        backgroundColor = .clear

        addSubview(bodyView)
        addSubview(calloutView)

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(gestureRecognizer)

        let constraints = directionalConstraints + [
            calloutView.centerXAnchor.constraint(equalTo: centerXAnchor),
            calloutView.widthAnchor.constraint(equalToConstant: 250),

            bodyView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bodyView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Actions

    @objc private func handleTap() {
        delegate?.calloutOverlayDidTapInside(self)
    }
}
