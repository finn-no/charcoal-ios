//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

protocol VerticalCalloutOverlayDelegate: AnyObject {
    func verticalCalloutOverlayDidTapInside(_ view: VerticalCalloutOverlay)
}

final class VerticalCalloutOverlay: UIView {
    private lazy var calloutView = CalloutView(withAutoLayout: true)

    private lazy var bodyView: UIView = {
        let view = UIView(withAutoLayout: true)
        view.backgroundColor = UIColor(white: 1, alpha: 0.8)
        return view
    }

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

        NSLayoutConstraint.activate([
            calloutView.topAnchor.constraint(equalTo: topAnchor, constant: 44),
            calloutView.centerXAnchor.constraint(equalTo: centerXAnchor),
            calloutView.widthAnchor.constraint(equalToConstant: 250),

            bodyView.topAnchor.constraint(equalTo: calloutView.topAnchor),
            bodyView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bodyView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bodyView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    // MARK: - Actions

    @objc private func handleButtonTap() {
        // delegate?.verticalSelectorViewDidSelectButton(self)
    }
}
