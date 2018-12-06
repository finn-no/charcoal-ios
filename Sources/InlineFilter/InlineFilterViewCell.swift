//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

class InlineFilterViewCell: UICollectionViewCell {
    static let cellHeight = 38 as CGFloat

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
        guard let view = view else { return }
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            view.heightAnchor.constraint(equalToConstant: InlineFilterViewCell.cellHeight),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}
