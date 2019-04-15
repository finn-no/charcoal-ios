//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

final class VerticalSelectorView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.captionStrong.withSize(12)
        label.textColor = .spaceGray
        label.textAlignment = .center
        return label
    }()

    private lazy var button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .milk
        button.titleLabel?.font = .bodyStrong
        button.setTitleColor(.primaryBlue, for: .normal)
        button.setTitleColor(.primaryBlue, for: .selected)
        button.setImage(UIImage(named: .arrowDown), for: .normal)

        // Layout the title and image
        semanticContentAttribute = .forceRightToLeft
        let spacing = .smallSpacing / 2
        button.imageEdgeInsets = UIEdgeInsets(top: 0, leading: spacing, bottom: 0, trailing: -spacing)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, leading: -spacing, bottom: 0, trailing: spacing)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, leading: .mediumLargeSpacing + spacing, bottom: 0, trailing: .mediumLargeSpacing + spacing)

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
        addSubview(titleLabel)
        addSubview(button)

        let stackView = UIStackView(arrangedSubviews: [titleLabel, button])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing

        addSubview(stackView)
        stackView.fillInSuperview()
    }
}
