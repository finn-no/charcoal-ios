//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

final class OnboardingCell: UICollectionViewCell {
    // MARK: - Private properties

    private static let imageHeight: CGFloat = 200

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

    // MARK: - Internal methods

    func configure(with model: OnboardingCellViewModel) {
        imageView.image = UIImage(named: model.imageAsset)
        textLabel.attributedText = model.attributedString
    }

    // MARK: - Private methods

    private func setup() {
        contentView.addSubview(imageView)
        contentView.addSubview(textLabel)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -OnboardingCell.imageHeight / 4),
            imageView.widthAnchor.constraint(equalToConstant: 320),
            imageView.heightAnchor.constraint(equalToConstant: 200),

            textLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: .mediumSpacing),
            textLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -.mediumSpacing),
            textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: .largeSpacing),
        ])
    }
}
