//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

final class SliderReferenceValueView: UIView {
    weak var leadingConstraint: NSLayoutConstraint?
    weak var midXConstraint: NSLayoutConstraint?
    let value: Int
    let displayText: String

    // MARK: - Views

    private lazy var indicatorView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .sardine
        view.layer.cornerRadius = 2.0
        return view
    }()

    private lazy var referenceLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: FontType.light.rawValue, size: 12)
        label.textColor = .licorice
        label.textAlignment = .center
        label.text = displayText

        return label
    }()

    // MARK: - Init

    init(value: Int, displayText: String) {
        self.value = value
        self.displayText = displayText
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    func setup() {
        addSubview(indicatorView)
        addSubview(referenceLabel)

        NSLayoutConstraint.activate([
            indicatorView.topAnchor.constraint(equalTo: topAnchor),
            indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicatorView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            indicatorView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            indicatorView.widthAnchor.constraint(equalToConstant: 4),
            indicatorView.heightAnchor.constraint(equalToConstant: 4),

            referenceLabel.topAnchor.constraint(equalTo: indicatorView.bottomAnchor, constant: .mediumSpacing),
            referenceLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            referenceLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            referenceLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}
