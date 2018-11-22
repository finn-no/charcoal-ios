//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class ErrorViewController: UIViewController {
    private let backgroundColor: UIColor
    private let textColor: UIColor
    private let actionTextColor: UIColor

    private lazy var messageLabel: UILabel = {
        let messageLabel = UILabel(frame: .zero)
        messageLabel.font = .body
        messageLabel.textColor = textColor
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        return messageLabel
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.setTitleColor(actionTextColor, for: .normal)
        button.titleLabel?.font = .title4
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var containerView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = .mediumLargeSpacing
        stackView.backgroundColor = .clear
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        return stackView
    }()

    private var actionCallback: (() -> Void)?

    // MARK: - Init

    init(backgroundColor: UIColor = UIColor.milk, textColor: UIColor = .licorice, actionTextColor: UIColor = .primaryBlue) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.actionTextColor = actionTextColor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func showError(_ errorText: String, actionTitle: String, actionCallback: @escaping () -> Void) {
        messageLabel.text = errorText
        actionButton.setTitle(actionTitle, for: .normal)
        self.actionCallback = actionCallback
    }

    private func setup() {
        super.viewDidLoad()

        view.backgroundColor = backgroundColor
        view.addSubview(containerView)
        containerView.addArrangedSubview(messageLabel)
        containerView.addArrangedSubview(actionButton)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: .mediumLargeSpacing),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -.mediumLargeSpacing),
            containerView.topAnchor.constraint(greaterThanOrEqualTo: safeTopAnchor, constant: .mediumLargeSpacing),
            containerView.bottomAnchor.constraint(lessThanOrEqualTo: safeBottomAnchor, constant: -.mediumLargeSpacing),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc private func didTapButton() {
        actionCallback?()
    }
}
