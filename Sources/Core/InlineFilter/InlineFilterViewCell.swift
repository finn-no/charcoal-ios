//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

class InlineFilterViewCell: UICollectionViewCell {
    static let cellHeight: CGFloat = 38

    var segment: Segment? {
        didSet {
            setupSubview(segment)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        segment?.removeFromSuperview()
    }
}

private extension InlineFilterViewCell {
    func setupSubview(_ view: UIView?) {
        guard let view = view else {
            return
        }
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentView.heightAnchor.constraint(equalToConstant: InlineFilterViewCell.cellHeight),
        ])
    }
}
