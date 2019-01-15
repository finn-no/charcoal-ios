//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol FilterBottomButtonViewDelegate: AnyObject {
    func filterBottomButtonView(_ filterBottomButtonView: FilterBottomButtonView, didTapButton button: UIButton)
}

class FilterBottomButtonView: UIView {
    weak var delegate: FilterBottomButtonViewDelegate?

    lazy var button: UIButton = {
        let button = UIButton(frame: .zero)
        button.backgroundColor = .primaryBlue
        button.setTitleColor(.milk, for: .normal)
        button.titleLabel?.font = .title4
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()

    private let buttonHeight: CGFloat = 52

    var height: CGFloat {
        return buttonHeight + .mediumLargeSpacing * 2.0
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
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)

        let separatorLine = UIView(frame: .zero)
        separatorLine.backgroundColor = .sardine
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorLine)

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor, constant: .mediumLargeSpacing),
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumLargeSpacing),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.mediumLargeSpacing),
            //            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.mediumLargeSpacing),
            button.heightAnchor.constraint(equalToConstant: buttonHeight),

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
