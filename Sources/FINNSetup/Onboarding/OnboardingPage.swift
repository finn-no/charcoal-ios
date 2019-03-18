//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

class OnboardingPage: UIViewController {

    // MARK: - Private properties

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(withAutoLayout: true)
        imageView.contentMode = .center
        return imageView
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel(withAutoLayout: true)
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Init

    init(imageName: String, attributedString: NSAttributedString) {
        super.init(nibName: nil, bundle: nil)
        let image = UIImage(named: imageName, in: Bundle.finnSetup, compatibleWith: nil)
        imageView.image = image
        textLabel.attributedText = attributedString
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - Private methods

    private func setup() {
        view.addSubview(imageView)
        view.addSubview(textLabel)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .mediumLargeSpacing),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: .mediumLargeSpacing),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.mediumLargeSpacing),
            imageView.bottomAnchor.constraint(equalTo: textLabel.topAnchor, constant: -.mediumLargeSpacing),

            textLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -.largeSpacing),
        ])
    }
}
