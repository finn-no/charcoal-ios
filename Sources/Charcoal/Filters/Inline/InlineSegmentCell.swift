//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

class InlineSegmentCell: UICollectionViewCell {
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

private extension InlineSegmentCell {
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
        ])
    }
}
