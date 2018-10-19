//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class PreferenceValueSelectionView: UIView {
    static let height: CGFloat = 38
    var height: CGFloat {
        return type(of: self).height
    }

    private lazy var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = height / 2
        view.layer.borderColor = .stone
        view.layer.borderWidth = 1.5
        return view
    }()

    private let preference: PreferenceInfoType
    weak var selectionDataSource: FilterSelectionDataSource?

    init(preference: PreferenceInfoType) {
        self.preference = preference
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .clear

        addSubview(contentView)

        var constraints = [NSLayoutConstraint]()

        for (index, _) in preference.values.enumerated() {
            let isFirst = index == 0
            let isLast = index == preference.values.count - 1
            let shouldBeSelected = isValueSelected(at: index)

            let button = UIButton(type: .custom)
            button.backgroundColor = .milk
            button.setTitleColor(.stone, for: .normal)
            button.setTitleColor(.milk, for: .selected)
            button.setTitle(valueTitle(at: index), for: .normal)
            button.setTitle(valueTitle(at: index), for: .selected)
            if !isFirst && !isLast {
                button.layer.borderWidth = contentView.layer.borderWidth
                button.layer.borderColor = contentView.layer.borderColor
            }

            if shouldBeSelected {
                button.backgroundColor = .primaryBlue
                button.isSelected = true
            }

            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: isFirst ? .mediumLargeSpacing : .mediumSpacing, bottom: 0, right: isLast ? .mediumLargeSpacing : .mediumSpacing)
            button.translatesAutoresizingMaskIntoConstraints = false

            let previousHorizontalAnchor = contentView.subviews.last?.trailingAnchor ?? contentView.leadingAnchor

            contentView.addSubview(button)

            constraints.append(contentsOf: [
                button.topAnchor.constraint(equalTo: contentView.topAnchor),
                button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                button.leadingAnchor.constraint(equalTo: previousHorizontalAnchor),
            ])
        }

        constraints.append(contentsOf: [
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        if let lastButtonTrailingAnchor = contentView.subviews.last?.trailingAnchor {
            constraints.append(contentView.trailingAnchor.constraint(equalTo: lastButtonTrailingAnchor))
        }

        NSLayoutConstraint.activate(constraints)
    }

    private func valueTitle(at index: Int) -> String {
        return preference.values[safe: index]?.title ?? ""
    }

    private func isValueSelected(at index: Int) -> Bool {
        guard let value = preference.values[safe: index], let selectionDataSource = selectionDataSource, let selectionsForPreference = selectionDataSource.value(for: preference) else {
            return false
        }
        return selectionsForPreference.contains(value.value)
    }
}
