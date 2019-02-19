//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

////
////  Copyright © FINN.no AS, Inc. All rights reserved.
////
//
// import UIKit
//
// class CCCollectionSelectionView: UIView, CCFilterSelectionView {
//
//    // MARK: - Public properties
//
//    var titles: [String] = []
//    weak var delegate: CCFilterSelectionViewDelegate?
//
//    var contentWidth: CGFloat {
//        return collectionViewWidthConstraint.constant
//    }
//
//    // MARK: - Private properties
//
//    private lazy var collectionViewWidthConstraint = collectionView.widthAnchor.constraint(equalToConstant: 0)
//
//    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.estimatedItemSize = CGSize(width: 50, height: 30)
//        layout.minimumLineSpacing = .mediumSpacing
//        return layout
//    }()
//
//    private lazy var collectionView: UICollectionView = {
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView.clipsToBounds = false
//        collectionView.isScrollEnabled = false
//        collectionView.backgroundColor = .milk
//        collectionView.register(CCCollectionSelectionViewCell.self)
//        collectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        return collectionView
//    }()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        collectionViewWidthConstraint.priority = .defaultLow
//        setup()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        collectionViewWidthConstraint.constant = collectionViewLayout.collectionViewContentSize.width
//    }
//
//    func add(titles: [String]) {
//        self.titles = titles
//        collectionView.reloadData()
//    }
// }
//
// extension CCCollectionSelectionView: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return titles.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeue(CCCollectionSelectionViewCell.self, for: indexPath)
//        cell.configure(for: titles[indexPath.item])
//        return cell
//    }
// }
//
// extension CCCollectionSelectionView: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        titles.remove(at: indexPath.item)
//        collectionView.deleteItems(at: [indexPath])
//        setNeedsLayout()
//        delegate?.selectionView(self, didRemoveItemAt: indexPath.item)
//    }
// }
//
// private extension CCCollectionSelectionView {
//    func setup() {
//        addSubview(collectionView)
//        NSLayoutConstraint.activate([
//            collectionViewWidthConstraint,
//            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            collectionView.topAnchor.constraint(equalTo: topAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
//        ])
//    }
// }
//
// private class CCCollectionSelectionViewCell: UICollectionViewCell {
//    private lazy var titleLabel: UILabel = {
//        let label = UILabel(frame: .zero)
//        label.font = .title5
//        label.textColor = .milk
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    private lazy var imageView: UIImageView = {
//        let imageView = UIImageView(image: UIImage(named: .removeFilterValue))
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        contentView.backgroundColor = .primaryBlue
//        contentView.layer.cornerRadius = 4
//        contentView.transform = CGAffineTransform(scaleX: -1, y: 1)
//        setup()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func configure(for title: String) {
//        titleLabel.text = title
//    }
//
//    private func setup() {
//        contentView.addSubview(titleLabel)
//        contentView.addSubview(imageView)
//        NSLayoutConstraint.activate([
//            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .mediumSpacing),
//            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .mediumSpacing),
//            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.mediumSpacing),
//
//            imageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: .smallSpacing),
//            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.mediumSpacing),
//        ])
//    }
// }
