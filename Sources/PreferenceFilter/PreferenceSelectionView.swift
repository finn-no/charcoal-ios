//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol PreferenceSelectionViewDelegate: AnyObject {
    func preferenceSelectionView(_ preferenceSelectionView: PreferenceSelectionView, didTapExpandablePreferenceAtIndex index: Int, view: ExpandablePreferenceButton)
}

public final class PreferenceSelectionView: UIView {
    public static let defaultButtonHeight: CGFloat = ExpandablePreferenceButton.height

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = false
        return scrollView
    }()

    private lazy var container: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = .mediumSpacing
        stackView.backgroundColor = .clear
        stackView.distribution = .fillProportionally

        return stackView
    }()

    private lazy var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    public var preferences: [PreferenceInfoType]? {
        didSet {
            reload()
        }
    }

    public weak var delegate: PreferenceSelectionViewDelegate?
    weak var selectionDataSource: FilterSelectionDataSource?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear

        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(container)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.heightAnchor.constraint(equalTo: heightAnchor),

            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
}

public extension PreferenceSelectionView {
    func expandablePreferenceClosed() {
        container.arrangedSubviews.forEach { view in
            if let expandableButton = view as? ExpandablePreferenceButton {
                expandableButton.isSelected = false
            }
        }
    }
}

private extension PreferenceSelectionView {
    func reload() {
        layoutButtonGroup()
    }

    func removeAllPreferences() {
        container.arrangedSubviews.forEach({ arrangedSubview in
            container.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        })
    }

    func layoutButtonGroup() {
        removeAllPreferences()

        guard let preferences = preferences else {
            return
        }

        let rangeOfItems = 0 ..< preferences.count
        // let buttonTitlesToDisplay = rangeOfItems.map { dataSource.preferenceSelectionView(self, titleForPreferenceAtIndex: $0) }
        // buttonTitlesToDisplay.forEach { layoutButton(with: $0) }

        rangeOfItems.forEach { index in
            if let preference = preferences[safe: index] {
                if preference.values.count > 0 {
                    layoutValueSectionView(with: preference)
                }
            }
        }
    }

    func layoutButton(with title: String) {
        let button = ExpandablePreferenceButton(title: title)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped(sender:forEvent:)), for: .touchUpInside)

        container.addArrangedSubview(button)

        let buttonSize = button.sizeForButtonExpandingHorizontally()

        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: ExpandablePreferenceButton.height),
            button.widthAnchor.constraint(equalToConstant: buttonSize.width),
        ])
    }

    func layoutValueSectionView(with preference: PreferenceInfoType) {
        let valueSelectionView = PreferenceValueSelectionView(preference: preference)
        valueSelectionView.selectionDataSource = selectionDataSource
        valueSelectionView.translatesAutoresizingMaskIntoConstraints = false

        container.addArrangedSubview(valueSelectionView)

        NSLayoutConstraint.activate([
            valueSelectionView.heightAnchor.constraint(equalToConstant: valueSelectionView.height),
        ])
    }

    @objc func buttonTapped(sender: UIButton, forEvent: UIEvent) {
        guard let index = container.arrangedSubviews.index(of: sender), let button = sender as? ExpandablePreferenceButton else {
            assertionFailure("No index for \(sender)")
            return
        }

        delegate?.preferenceSelectionView(self, didTapExpandablePreferenceAtIndex: index, view: button)
    }
}
