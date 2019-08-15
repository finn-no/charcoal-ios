//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

final class OnboardingCell: UICollectionViewCell {
    // MARK: - Private properties

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, textLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = .largeSpacing
        return stackView
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
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
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 320),
            imageView.heightAnchor.constraint(equalToConstant: 200),
        ])
    }
}
