//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class InlineFilterCell: UITableViewCell {
    let inlineFilterView: InlineFilterView

    init(inlineFilterView: InlineFilterView) {
        self.inlineFilterView = inlineFilterView
        super.init(style: .default, reuseIdentifier: nil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension InlineFilterCell {
    func setup() {
        contentView.addSubview(inlineFilterView)
        NSLayoutConstraint.activate([
            inlineFilterView.leadingAnchor.constraint(equalTo: leadingAnchor),
            inlineFilterView.topAnchor.constraint(equalTo: topAnchor),
            inlineFilterView.trailingAnchor.constraint(equalTo: trailingAnchor),
            inlineFilterView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
