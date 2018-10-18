//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class ExpandablePreferenceButton: UIButton {
    private let borderWidth: CGFloat = 1.5
    static let height: CGFloat = 38

    init(title: String) {
        super.init(frame: .zero)
        backgroundColor = .milk
        contentEdgeInsets = UIEdgeInsets(top: .mediumSpacing, left: .mediumSpacing, bottom: .mediumSpacing, right: .mediumSpacing)
        semanticContentAttribute = .forceRightToLeft
        layer.borderWidth = borderWidth
        layer.borderColor = .stone
        layer.cornerRadius = ExpandablePreferenceButton.height / 2
        imageView?.tintColor = .stone
        imageView?.contentMode = .scaleAspectFit
        setImage(UIImage(named: .arrowDown), for: .normal)
        setImage(UIImage(named: .arrowDown), for: .highlighted)
        setImage(UIImage(named: .arrowDown), for: .selected)
        imageEdgeInsets = UIEdgeInsets(top: 0, left: .mediumSpacing, bottom: 0, right: 0)
        setAttributedTitle(attributedButtonTitle(from: title, for: .normal), for: .normal)
        setAttributedTitle(attributedButtonTitle(from: title, for: .highlighted), for: .highlighted)
        setAttributedTitle(attributedButtonTitle(from: title, for: .selected), for: .selected)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isSelected: Bool {
        set {
            super.isSelected = newValue
            layer.borderWidth = newValue ? 0 : borderWidth
        }
        get {
            return super.isSelected
        }
    }

    func sizeForButtonExpandingHorizontally() -> CGSize {
        let boundingRectSize = CGSize(width: .infinity, height: ExpandablePreferenceButton.height)
        let attributedTitle = self.attributedTitle(for: .normal) ?? NSAttributedString()
        let rect = attributedTitle.boundingRect(with: boundingRectSize, options: .usesLineFragmentOrigin, context: nil)
        let verticalSpacings: CGFloat = .mediumSpacing + .mediumSpacing + 18 + .mediumSpacing
        let size = CGSize(width: rect.width + verticalSpacings, height: rect.height)

        return size
    }
}

private extension ExpandablePreferenceButton {
    private func attributedButtonTitle(from string: String, for state: UIControl.State) -> NSAttributedString {
        let attributes = titleAttributes(for: state)
        let attributedTitle = NSAttributedString(string: string, attributes: attributes)

        return attributedTitle
    }

    private func titleAttributes(for state: UIControl.State) -> [NSAttributedString.Key: Any]? {
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

        return [.font: font, .foregroundColor: foregroundColor]
    }
}
