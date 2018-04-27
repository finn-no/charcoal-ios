//
//  Copyright © 2018 FINN.no. All rights reserved.
//

import Foundation

public protocol HorizontalScrollButtonGroupDataSource: AnyObject {
    func horizontalScrollButtonGroup(_ horizontalScrollButtonGroup: HorizontalScrollButtonGroup, titleForButtonAtIndex index: Int) -> String?
    func numberOfButtons(_ horizontalScrollButtonGroup: HorizontalScrollButtonGroup) -> Int
}

public protocol HorizontalScrollButtonGroupDelegate: AnyObject {
    func horizontalScrollButtonGroup(_ horizontalScrollButtonGroup: HorizontalScrollButtonGroup, didTapButton button: UIButton, atIndex index: Int)
}

public final class HorizontalScrollButtonGroup: UIView {
    
    public static var defaultButtonHeight: CGFloat = 38
    static var defaultButtonBorderWidth: CGFloat = 1.5
 
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        
        return scrollView
    }()
    
    private lazy var stackView: UIStackView = {
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
    
    private lazy var buttonImage: UIImage! = {
        return UIImage(named: "arrowDown", in: Bundle(for: HorizontalScrollButtonGroup.self), compatibleWith: nil)!
    }()
    
    public weak var dataSource: HorizontalScrollButtonGroupDataSource? {
        didSet {
            self.reload()
        }
    }
    
    public weak var delegate: HorizontalScrollButtonGroupDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtonsContainer()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButtonsContainer()
    }
    
    func setupButtonsContainer() {
        backgroundColor = .clear
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
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
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ])
    }
}


// MARK: - PUBLIC
public extension HorizontalScrollButtonGroup {
    func reload() {
        layoutButtonGroup()
    }
    
    func removeAllButtons() {
        stackView.arrangedSubviews.forEach({ arrangedSubview in
            stackView.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        })
    }
    
    func setButton(at index: Int, selected: Bool) {
        guard stackView.arrangedSubviews.indices.contains(index) else {
            return
        }
        
        let buttons = stackView.arrangedSubviews as! [UIButton]
        let button = buttons[index]
        let state = selected ? UIControlState.selected : .normal
        let attributedTitle = attributedButtonTitle(from: button.currentAttributedTitle?.string, for: state)
        let showsBorder = state == .selected ? false : true
        
        button.isSelected = selected
        button.setAttributedTitle(attributedTitle, for: state)
        button.layer.borderWidth = showsBorder ? HorizontalScrollButtonGroup.defaultButtonBorderWidth : 0.0
    }
    
    func rectForButton(at index: Int, convertedToRectInView view: UIView? = nil) -> CGRect? {
        guard stackView.arrangedSubviews.indices.contains(index) else {
            return nil
        }
        
        let rect = stackView.arrangedSubviews[index].frame
        
        if let conversionView = view {
            return convert(rect, to: conversionView)
        } else {
            return rect
        }
    }
    
    var indexesForSelectedButtons: [Int] {
        let buttons = stackView.arrangedSubviews as! [UIButton]
        let seletectedButtons =  buttons.filter({ $0.isSelected })
        let indexesOfSelectedButtons = seletectedButtons.compactMap({ buttons.index(of: $0) })
        
        return indexesOfSelectedButtons
    }
}


// MARK: - BUTTONS (PRIVATE)
private extension HorizontalScrollButtonGroup {
    func layoutButtonGroup() {
        removeAllButtons()
        
        guard let dataSource = dataSource else {
            return
        }
        
        let rangeOfButtons = 0 ..< dataSource.numberOfButtons(self)
        let buttonTitlesToDisplay = rangeOfButtons.map { dataSource.horizontalScrollButtonGroup(self, titleForButtonAtIndex: $0)}
        
        buttonTitlesToDisplay.forEach { layoutButton(with: $0) }
    }
    
    func layoutButton(with title: String?) {
        let button = makeButton()
        let buttonStates = [UIControlState.normal, .highlighted, .selected]
        
        buttonStates.forEach({ state in
            let attributedTitle = attributedButtonTitle(from: title, for: state)
            button.setAttributedTitle(attributedTitle, for: state)
        })
        
        stackView.addArrangedSubview(button)
        
        let buttonSize = sizeForButton(with: attributedButtonTitle(from: title, for: .normal))
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 1, constant: 0),
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
    
    func makeButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped(sender:forEvent:)), for: .touchUpInside)
        button.backgroundColor = .milk
        button.contentEdgeInsets = UIEdgeInsets(top: .mediumSpacing, left: .mediumSpacing, bottom: .mediumSpacing, right: .mediumSpacing)
        button.semanticContentAttribute = .forceRightToLeft
       
        button.layer.borderWidth = HorizontalScrollButtonGroup.defaultButtonBorderWidth
        button.layer.borderColor = .stone
        button.layer.cornerRadius = HorizontalScrollButtonGroup.defaultButtonHeight / 2
        
        button.setImage(buttonImage, for: .normal)
        button.setImage(buttonImage, for: .highlighted)
        button.setImage(buttonImage, for: .selected)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: .mediumSpacing, bottom: 0, right: 0)
        
        return button
    }
    
    func sizeForButton(with attributedTitle: NSAttributedString?) -> CGSize {
        guard let attributedTitle = attributedTitle else {
            return .zero
        }
        
        let boundingRectSize = CGSize(width: CGFloat.infinity, height: HorizontalScrollButtonGroup.defaultButtonHeight)
        let rect = attributedTitle.boundingRect(with: boundingRectSize, options: .usesLineFragmentOrigin, context: nil)
        let verticalSpacings: CGFloat = .mediumSpacing + .mediumSpacing + 18 + .mediumSpacing
        let size = CGSize(width: rect.width + verticalSpacings, height: rect.height)
        
        return size
    }
}

private extension HorizontalScrollButtonGroup {
    @objc func buttonTapped(sender: UIButton, forEvent: UIEvent) {
        guard let buttonIndex = stackView.arrangedSubviews.index(of: sender) else {
            assertionFailure("No index for \(sender)")
            return
        }
        
        delegate?.horizontalScrollButtonGroup(self, didTapButton: sender, atIndex: buttonIndex)
    }
}
