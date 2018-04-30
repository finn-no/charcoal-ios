//
//  Copyright © 2018 FINN.no. All rights reserved.
//

import Foundation

public protocol HorizontalScrollButtonGroupViewDataSource: AnyObject {
    func horizontalScrollButtonGroupView(_ horizontalScrollButtonGroupView: HorizontalScrollButtonGroupView, titleForButtonAtIndex index: Int) -> String?
    func numberOfButtons(_ horizontalScrollButtonGroupView: HorizontalScrollButtonGroupView) -> Int
}

public protocol HorizontalScrollButtonGroupViewDelegate: AnyObject {
    func horizontalScrollButtonGroupView(_ horizontalScrollButtonGroupView: HorizontalScrollButtonGroupView, didTapButton button: UIButton, atIndex index: Int)
}

public final class HorizontalScrollButtonGroupView: UIView {
    
    public static var defaultButtonHeight: CGFloat = 38
    static var defaultButtonBorderWidth: CGFloat = 1.5
 
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        
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
        return UIImage(named: "arrowDown", in: Bundle(for: HorizontalScrollButtonGroupView.self), compatibleWith: nil)!
    }()
    
    public weak var dataSource: HorizontalScrollButtonGroupViewDataSource? {
        didSet {
            self.reload()
        }
    }
    
    public weak var delegate: HorizontalScrollButtonGroupViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
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


public extension HorizontalScrollButtonGroupView {
    func reload() {
        layoutButtonGroup()
    }
    
    func removeAllButtons() {
        container.arrangedSubviews.forEach({ arrangedSubview in
            container.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        })
    }
    
    func setButton(at index: Int, selected: Bool) {
        guard container.arrangedSubviews.indices.contains(index) else {
            return
        }
        
        guard let buttons = container.arrangedSubviews as? [UIButton] else {
            assertionFailure("Expected subviews to be array of only buttons ")
            return
        }
        
        let button = buttons[index]
        let state = selected ? UIControlState.selected : .normal
        let attributedTitle = attributedButtonTitle(from: button.currentAttributedTitle?.string, for: state)
        let showsBorder = state == .selected ? false : true
        
        button.isSelected = selected
        button.setAttributedTitle(attributedTitle, for: state)
        button.layer.borderWidth = showsBorder ? HorizontalScrollButtonGroupView.defaultButtonBorderWidth : 0.0
    }
    
    func rectForButton(at index: Int, convertedToRectInView view: UIView? = nil) -> CGRect? {
        guard container.arrangedSubviews.indices.contains(index) else {
            return nil
        }
        
        let rect = container.arrangedSubviews[index].frame
        
        if let conversionView = view {
            return convert(rect, to: conversionView)
        } else {
            return rect
        }
    }
    
    var indexesForSelectedButtons: [Int] {
        guard let buttons = container.arrangedSubviews as? [UIButton] else {
            assertionFailure("Expected subviews to be array of only buttons ")
            return []
        }
        
        let seletectedButtons =  buttons.filter({ $0.isSelected })
        let indexesOfSelectedButtons = seletectedButtons.compactMap({ buttons.index(of: $0) })
        
        return indexesOfSelectedButtons
    }
}

private extension HorizontalScrollButtonGroupView {
    func layoutButtonGroup() {
        removeAllButtons()
        
        guard let dataSource = dataSource else {
            return
        }
        
        let rangeOfButtons = 0 ..< dataSource.numberOfButtons(self)
        let buttonTitlesToDisplay = rangeOfButtons.map { dataSource.horizontalScrollButtonGroupView(self, titleForButtonAtIndex: $0)}
        
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
            button.widthAnchor.constraint(equalToConstant: buttonSize.width)
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
        
        let boundingRectSize = CGSize(width: CGFloat.infinity, height: HorizontalScrollButtonGroupView.defaultButtonHeight)
        let rect = attributedTitle.boundingRect(with: boundingRectSize, options: .usesLineFragmentOrigin, context: nil)
        let verticalSpacings: CGFloat = .mediumSpacing + .mediumSpacing + 18 + .mediumSpacing
        let size = CGSize(width: rect.width + verticalSpacings, height: rect.height)
        
        return size
    }
    
    @objc func buttonTapped(sender: UIButton, forEvent: UIEvent) {
        guard let buttonIndex = container.arrangedSubviews.index(of: sender) else {
            assertionFailure("No index for \(sender)")
            return
        }
        
        delegate?.horizontalScrollButtonGroupView(self, didTapButton: sender, atIndex: buttonIndex)
    }
}

private extension UIButton {
    convenience init(with image: UIImage?) {
        self.init(type: .custom)
        backgroundColor = .milk
        contentEdgeInsets = UIEdgeInsets(top: .mediumSpacing, left: .mediumSpacing, bottom: .mediumSpacing, right: .mediumSpacing)
        semanticContentAttribute = .forceRightToLeft
        layer.borderWidth = HorizontalScrollButtonGroupView.defaultButtonBorderWidth
        layer.borderColor = .stone
        layer.cornerRadius = HorizontalScrollButtonGroupView.defaultButtonHeight / 2
        imageView?.tintColor = .stone
        imageView?.contentMode = .scaleAspectFit
        setImage(image, for: .normal)
        setImage(image, for: .highlighted)
        setImage(image, for: .selected)
        imageEdgeInsets = UIEdgeInsets(top: 0, left: .mediumSpacing, bottom: 0, right: 0)
    }
}
