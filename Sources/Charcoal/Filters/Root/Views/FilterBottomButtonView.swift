//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import Warp

protocol FilterBottomButtonViewDelegate: AnyObject {
    func filterBottomButtonView(_ filterBottomButtonView: FilterBottomButtonView, didTapButton button: UIButton)
}

class FilterBottomButtonView: ShadowView {
    weak var delegate: FilterBottomButtonViewDelegate?

    private lazy var button: Button = {
        let button = Button(style: .callToAction)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override var intrinsicContentSize: CGSize {
        return CGSize(width: button.intrinsicContentSize.width,
                      height: button.intrinsicContentSize.height + Warp.Spacing.spacing400 + windowSafeAreaInsets.bottom)
    }

    var isEnabled = true {
        didSet {
            button.isEnabled = isEnabled
        }
    }

    override init() {
        super.init()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}

private extension FilterBottomButtonView {
    func setup() {
        addSubview(button)

        let bottomConstant: CGFloat = Warp.Spacing.spacing200 + windowSafeAreaInsets.bottom

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor, constant: Warp.Spacing.spacing200),
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Warp.Spacing.spacing200),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Warp.Spacing.spacing200),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottomConstant),
        ])
    }

    @objc func didTapButton() {
        delegate?.filterBottomButtonView(self, didTapButton: button)
    }
}

extension FilterBottomButtonView {
    var buttonTitle: String? {
        get {
            return button.title(for: .normal)
        }
        set {
            button.setTitle(newValue, for: .normal)
        }
    }
}
