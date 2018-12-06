//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

final class RangeReferenceValueView: UIView {
    lazy var indicatorView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .sardine
        view.layer.cornerRadius = 2.0
        return view
    }()

    weak var leadingConstraint: NSLayoutConstraint?
    weak var midXConstraint: NSLayoutConstraint?

    lazy var referenceLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: FontType.light.rawValue, size: 12)
        label.textColor = .licorice
        label.textAlignment = .center
        label.text = text

        return label
    }()

    let value: Int
    let text: String?

    init(value: RangeFilterView.RangeValue, unit: String, formatter: RangeFilterValueFormatter) {
        self.value = value
        text = formatter.string(from: value)?.appending(" \(unit)")
        super.init(frame: .zero)

        setup()
    }

    init(value: RangeFilterView.RangeValue, text: String) {
        self.value = value
        self.text = text
        super.init(frame: .zero)

        setup()
    }

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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
