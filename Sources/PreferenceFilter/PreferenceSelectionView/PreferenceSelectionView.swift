//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol PreferenceSelectionViewDataSource: AnyObject {
    func preferenceSelectionView(_ preferenceSelectionView: PreferenceSelectionView, titleForPreferenceAtIndex index: Int) -> String?
    func numberOfPreferences(_ preferenceSelectionView: PreferenceSelectionView) -> Int
}

public protocol PreferenceSelectionViewDelegate: AnyObject {
    func preferenceSelectionView(_ preferenceSelectionView: PreferenceSelectionView, didTapPreferenceAtIndex index: Int)
}

public final class PreferenceSelectionView: UIView {
    public static var defaultButtonHeight: CGFloat = 38
    static var defaultButtonBorderWidth: CGFloat = 1.5

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

    private lazy var buttonImage: UIImage = {
        return UIImage(named: .arrowDown)
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
        guard let button = container.arrangedSubview(atSafeIndex: index) as? UIButton else {
            assertionFailure("Expected subviews to be array of only buttons ")
            return
        }

        let state = selected ? UIControlState.selected : .normal
        let attributedTitle = attributedButtonTitle(from: button.currentAttributedTitle?.string, for: state)
        let showsBorder = state == .selected ? false : true

        button.isSelected = selected
        button.setAttributedTitle(attributedTitle, for: state)
        button.layer.borderWidth = showsBorder ? PreferenceSelectionView.defaultButtonBorderWidth : 0.0
    }

    func rectForPreference(at index: Int, convertedToRectInView view: UIView? = nil) -> CGRect? {
        guard let rect = container.arrangedSubview(atSafeIndex: index)?.frame else {
            return nil
        }

        if let conversionView = view {
            return convert(rect, to: conversionView)
        } else {
            return rect
        }
    }

    func viewForPreference(at index: Int) -> UIView? {
        return container.arrangedSubview(atSafeIndex: index)
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
        guard let button = container.arrangedSubview(atSafeIndex: index) as? UIButton else {
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

    func layoutButton(with title: String?) {
        let button = UIButton(with: buttonImage)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped(sender:forEvent:)), for: .touchUpInside)

        let buttonStates = [UIControlState.normal, .highlighted, .selected]

        buttonStates.forEach({ state in
            let attributedTitle = attributedButtonTitle(from: title, for: state)
            button.setAttributedTitle(attributedTitle, for: state)
        })

        container.addArrangedSubview(button)

        let buttonSize = sizeForButton(with: attributedButtonTitle(from: title, for: .normal))

        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1, constant: 0),
            button.widthAnchor.constraint(equalToConstant: buttonSize.width),
        ])
    }

    func attributedButtonTitle(from string: String?, for state: UIControlState) -> NSAttributedString? {
        guard let string = string else {
            return nil
        }

        let attributes = titleAttributes(for: state)
        let attributedTitle = NSAttributedString(string: string, attributes: attributes)

        return attributedTitle
    }

    func titleAttributes(for state: UIControlState) -> [NSAttributedStringKey: Any]? {
        let font: UIFont = .title5
        let foregroundColor: UIColor

        switch state {
        case .normal:
            foregroundColor = .stone
        case .highlighted:
            foregroundColor = UIColor.stone.withAlphaComponent(0.8)
        case .selected:
            foregroundColor = .primaryBlue
        default:
            return nil
        }

        return [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: foregroundColor]
    }

    func sizeForButton(with attributedTitle: NSAttributedString?) -> CGSize {
        guard let attributedTitle = attributedTitle else {
            return .zero
        }

        let boundingRectSize = CGSize(width: CGFloat.infinity, height: PreferenceSelectionView.defaultButtonHeight)
        let rect = attributedTitle.boundingRect(with: boundingRectSize, options: .usesLineFragmentOrigin, context: nil)
        let verticalSpacings: CGFloat = .mediumSpacing + .mediumSpacing + 18 + .mediumSpacing
        let size = CGSize(width: rect.width + verticalSpacings, height: rect.height)

        return size
    }

    @objc func buttonTapped(sender: UIButton, forEvent: UIEvent) {
        guard let index = container.arrangedSubviews.index(of: sender) else {
            assertionFailure("No index for \(sender)")
            return
        }

        delegate?.preferenceSelectionView(self, didTapPreferenceAtIndex: index)
    }
}

private extension UIButton {
    convenience init(with image: UIImage?) {
        self.init(type: .custom)
        backgroundColor = .milk
        contentEdgeInsets = UIEdgeInsets(top: .mediumSpacing, left: .mediumSpacing, bottom: .mediumSpacing, right: .mediumSpacing)
        semanticContentAttribute = .forceRightToLeft
        layer.borderWidth = PreferenceSelectionView.defaultButtonBorderWidth
        layer.borderColor = .stone
        layer.cornerRadius = PreferenceSelectionView.defaultButtonHeight / 2
        imageView?.tintColor = .stone
        imageView?.contentMode = .scaleAspectFit
        setImage(image, for: .normal)
        setImage(image, for: .highlighted)
        setImage(image, for: .selected)
        imageEdgeInsets = UIEdgeInsets(top: 0, left: .mediumSpacing, bottom: 0, right: 0)
    }
}

private extension UIStackView {
    func arrangedSubview(atSafeIndex safeIndex: Int) -> UIView? {
        guard arrangedSubviews.indices.contains(safeIndex) else {
            return nil
        }

        return arrangedSubviews[safeIndex]
    }
}
