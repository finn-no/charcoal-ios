//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

protocol FilterBottomButtonViewDelegate: AnyObject {
    func filterBottomButtonView(_ filterBottomButtonView: FilterBottomButtonView, didTapButton button: UIButton)
}

class FilterBottomButtonView: UIView {
    weak var delegate: FilterBottomButtonViewDelegate?

    private lazy var button: Button = {
        let button = Button(style: .callToAction)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override var intrinsicContentSize: CGSize {
        return CGSize(width: button.intrinsicContentSize.width,
                      height: button.intrinsicContentSize.height + .largeSpacing)
    }

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}

private extension FilterBottomButtonView {
    func setup() {
        backgroundColor = .milk
        addSubview(button)

        let separatorLine = UIView(frame: .zero)
        separatorLine.backgroundColor = .sardine
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorLine)

        let bottomConstant: CGFloat = .mediumLargeSpacing + windowSafeAreaInsets.bottom

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor, constant: .mediumLargeSpacing),
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumLargeSpacing),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.mediumLargeSpacing),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottomConstant),

            separatorLine.topAnchor.constraint(equalTo: topAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
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
