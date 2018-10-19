//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol PreferenceSelectionViewDelegate: AnyObject {
    func preferenceSelectionView(_ preferenceSelectionView: PreferenceSelectionView, didTapPreferenceAtIndex index: Int)
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
    func setPreference(at index: Int, selected: Bool) {
        guard let button = container.arrangedSubviews[safe: index] as? ExpandablePreferenceButton else {
            assertionFailure("Expected subviews to be array of only buttons ")
            return
        }

        button.isSelected = selected
    }

    func rectForPreference(at index: Int, convertedToRectInView view: UIView? = nil) -> CGRect? {
        guard let rect = container.arrangedSubviews[safe: index]?.frame else {
            return nil
        }

        if let conversionView = view {
            return convert(rect, to: conversionView)
        } else {
            return rect
        }
    }

    func viewForPreference(at index: Int) -> UIView? {
        return container.arrangedSubviews[safe: index]
    }

    var indexesForSelectedPreferences: [Int] {
        guard let buttons = container.arrangedSubviews as? [UIButton] else {
            assertionFailure("Expected subviews to be array of only buttons ")
            return []
        }

        let seletectedButtons = buttons.filter({ $0.isSelected })
        let indexesOfSelectedButtons = seletectedButtons.compactMap({ buttons.index(of: $0) })

        return indexesOfSelectedButtons
    }

    func isPreferenceSelected(at index: Int) -> Bool {
        guard let button = container.arrangedSubviews[safe: index] as? UIButton else {
            return false
        }

        return button.isSelected
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
        guard let index = container.arrangedSubviews.index(of: sender) else {
            assertionFailure("No index for \(sender)")
            return
        }

        delegate?.preferenceSelectionView(self, didTapPreferenceAtIndex: index)
    }
}
