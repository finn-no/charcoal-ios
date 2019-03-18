//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

struct OnboardingCellViewModel {
    var imageName: String
    var attributedString: NSAttributedString
}

class OnboardingCell: UICollectionViewCell {

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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override func prepareForReuse() {
        imageView.image = nil
        textLabel.attributedText = nil
    }

    // MARK: - Public methods

    func configure(with model: OnboardingCellViewModel) {
        let image = UIImage(named: model.imageName, in: Bundle.finnSetup, compatibleWith: nil)
        imageView.image = image
        textLabel.attributedText = model.attributedString
    }

    // MARK: - Private methods

    private func setup() {
        contentView.addSubview(imageView)
        contentView.addSubview(textLabel)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .mediumLargeSpacing),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .mediumLargeSpacing),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.mediumLargeSpacing),
            imageView.bottomAnchor.constraint(equalTo: textLabel.topAnchor, constant: -.mediumLargeSpacing),

            textLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.largeSpacing),
        ])
    }
}
