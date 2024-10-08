//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import Warp

protocol VerticalSelectorViewDelegate: AnyObject {
    func verticalSelectorViewDidSelectButton(_ view: VerticalSelectorView)
}

final class VerticalSelectorView: UIView {
    enum ArrowDirection {
        case up
        case down
    }

    weak var delegate: VerticalSelectorViewDelegate?

    var arrowDirection: ArrowDirection = .down {
        didSet {
            let asset: CharcoalImageAsset = arrowDirection == .up ? .arrowUp : .arrowDown
            button.setImage(UIImage(named: asset).withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }

    var isEnabled: Bool = true {
        didSet {
            button.isEnabled = isEnabled
        }
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel(withAutoLayout: true)
        label.font = UIFont.detailStrong
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .textSubtle
        label.textAlignment = .center
        return label
    }()

    private lazy var button: UIButton = {
        let button = UIButton(withAutoLayout: true)
        button.titleLabel?.font = UIFont.bodyStrong
        button.titleLabel?.adjustsFontForContentSizeCategory = true

        button.tintColor = .textLink
        button.setTitleColor(.textLink, for: .normal)
        button.setTitleColor(.textLink.withAlphaComponent(0.8), for: .highlighted)
        button.setTitleColor(.textLink.withAlphaComponent(0.8), for: .selected)
        button.setTitleColor(.textLink.withAlphaComponent(0.5), for: .disabled)

        let spacing = Warp.Spacing.spacing50 / 2

        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: spacing, leading: spacing, bottom: 0, trailing: -spacing)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, leading: -spacing, bottom: 0, trailing: spacing)
        button.contentEdgeInsets = UIEdgeInsets(
            top: titleLabel.font.pointSize,
            leading: Warp.Spacing.spacing200 + spacing,
            bottom: 0,
            trailing: Warp.Spacing.spacing200 + spacing
        )

        button.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)

        return button
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    func configure(withTitle title: String, buttonTitle: String) {
        titleLabel.text = title
        button.setTitle(buttonTitle, for: .normal)
    }

    private func setup() {
        arrowDirection = .down
        isEnabled = true

        addSubview(titleLabel)
        addSubview(button)

        button.fillInSuperview()

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            button.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
        ])
    }

    // MARK: - Actions

    @objc private func handleButtonTap() {
        delegate?.verticalSelectorViewDidSelectButton(self)
    }
}
