//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import Foundation

class InfoView: UIView {
    // MARK: - Subviews

    private lazy var boxView: UIView = {
        let view = UIView(withAutoLayout: true)
        view.backgroundColor = .bgPrimary
        view.layer.cornerRadius = .spacingM

        view.dropShadow(color: .black, opacity: 0.2, offset: CGSize(width: 0, height: 1), radius: 5)
        return view
    }()

    private lazy var label: Label = {
        let label = Label(style: .detailStrong, withAutoLayout: true)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        alpha = 0

        addSubview(boxView)
        boxView.addSubview(label)

        boxView.fillInSuperview()

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: boxView.topAnchor, constant: .spacingS),
            label.leadingAnchor.constraint(equalTo: boxView.leadingAnchor, constant: .spacingXL),
            label.trailingAnchor.constraint(equalTo: boxView.trailingAnchor, constant: -.spacingXL),
            label.bottomAnchor.constraint(equalTo: boxView.bottomAnchor, constant: -.spacingS),
        ])
    }

    // MARK: - API

    func show(with text: String, completion: (() -> Void)?) {
        label.text = text
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.alpha = 1
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            feedbackGenerator.impactOccurred()
        }, completion: { [weak self] _ in
            UIView.animate(withDuration: 0.2, delay: 5, options: .curveEaseOut, animations: {
                self?.alpha = 0.0
            }, completion: { _ in
                completion?()
            })
        })
    }
}
