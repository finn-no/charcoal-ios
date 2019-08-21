//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

protocol BottomButtonCalloutOverlayDelegate: AnyObject {
    func bottomButtomCalloutOverlayDidTapInside(_ view: BottomButtonCalloutOverlay)
}

final class BottomButtonCalloutOverlay: UIView {
    weak var delegate: BottomButtonCalloutOverlayDelegate?

    // MARK: - Private properties

    private lazy var calloutView: CalloutView = {
        let view = CalloutView(direction: .down)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var bodyView: UIView = {
        let view = UIView(withAutoLayout: true)
        view.backgroundColor = UIColor(white: 1, alpha: 0.8)
        return view
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    func configure(withText text: String) {
        calloutView.show(withText: text, duration: 0)
    }

    private func setup() {
        backgroundColor = .clear

        addSubview(bodyView)
        addSubview(calloutView)

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(gestureRecognizer)

        NSLayoutConstraint.activate([
            calloutView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -76),
            calloutView.centerXAnchor.constraint(equalTo: centerXAnchor),
            calloutView.widthAnchor.constraint(equalToConstant: 250),

            bodyView.topAnchor.constraint(equalTo: topAnchor),
            bodyView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bodyView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bodyView.bottomAnchor.constraint(equalTo: calloutView.bottomAnchor),

        ])
    }

    // MARK: - Actions

    @objc private func handleTap() {
        delegate?.bottomButtomCalloutOverlayDidTapInside(self)
    }
}
