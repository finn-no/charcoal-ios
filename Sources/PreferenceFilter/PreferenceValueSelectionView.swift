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
        view.layer.borderColor = .silver
        view.layer.borderWidth = 1.5
        view.clipsToBounds = true
        return view
    }()

    private let preference: PreferenceInfoType
    weak var selectionDataSource: FilterSelectionDataSource? {
        didSet {
            contentView.subviews.forEach { subview in
                guard let button = subview as? PreferenceValueSelectionButton else {
                    return
                }
                button.isPreferenceValueSelected = isValueSelected(for: button.preferenceValue)
            }
        }
    }

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

        for (index, value) in preference.values.enumerated() {
            let isFirst = index == 0
            let isLast = index == preference.values.count - 1
            let shouldBeSelected = isValueSelected(at: index)

            let button = PreferenceValueSelectionButton(preferenceValue: value)
            button.addTarget(self, action: #selector(didTapButton(button:)), for: .touchUpInside)

            if shouldBeSelected {
                button.isPreferenceValueSelected = true
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

            if !isLast {
                let separatorLine = UIView(frame: .zero)
                separatorLine.backgroundColor = .silver
                separatorLine.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(separatorLine)
                constraints.append(contentsOf: [
                    separatorLine.topAnchor.constraint(equalTo: contentView.topAnchor),
                    separatorLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                    separatorLine.leadingAnchor.constraint(equalTo: button.trailingAnchor),
                    separatorLine.widthAnchor.constraint(equalToConstant: contentView.layer.borderWidth),
                ])
            }
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

    private func isValueSelected(for value: PreferenceValueType) -> Bool {
        guard let selectionDataSource = selectionDataSource, let selectionsForPreference = selectionDataSource.value(for: preference) else {
            return false
        }
        return selectionsForPreference.contains(value.value)
    }

    @objc private func didTapButton(button: UIButton) {
        guard let button = button as? PreferenceValueSelectionButton else {
            return
        }
        guard let selectionDataSource = selectionDataSource else {
            return
        }
        if isValueSelected(for: button.preferenceValue) {
            selectionDataSource.clearValue(button.preferenceValue.value, for: preference)
            button.isPreferenceValueSelected = false
        } else {
            selectionDataSource.addValue(button.preferenceValue.value, for: preference)
            button.isPreferenceValueSelected = true
        }
    }
}
