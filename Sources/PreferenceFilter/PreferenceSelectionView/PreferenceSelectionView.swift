//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol PreferenceSelectionViewDataSource: AnyObject {
    func preferenceSelectionView(_ preferenceSelectionView: PreferenceSelectionView, titleForPreferenceAtIndex index: Int) -> String
    func numberOfPreferences(_ preferenceSelectionView: PreferenceSelectionView) -> Int
}

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

    public var dataSource: PreferenceSelectionViewDataSource? {
        didSet {
            reload()
        }
    }

    public weak var delegate: PreferenceSelectionViewDelegate?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
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
    func reload() {
        layoutButtonGroup()
    }

    func removeAllPreferences() {
        container.arrangedSubviews.forEach({ arrangedSubview in
            container.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        })
    }

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
    func layoutButtonGroup() {
        removeAllPreferences()

        guard let dataSource = dataSource else {
            return
        }

        let rangeOfButtons = 0 ..< dataSource.numberOfPreferences(self)
        let buttonTitlesToDisplay = rangeOfButtons.map { dataSource.preferenceSelectionView(self, titleForPreferenceAtIndex: $0) }

        buttonTitlesToDisplay.forEach { layoutButton(with: $0) }
    }

    func layoutButton(with title: String) {
        let button = ExpandablePreferenceButton(title: title)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped(sender:forEvent:)), for: .touchUpInside)

        container.addArrangedSubview(button)

        let buttonSize = button.sizeForButtonExpandingHorizontally()

        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1, constant: 0),
            button.widthAnchor.constraint(equalToConstant: buttonSize.width),
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
