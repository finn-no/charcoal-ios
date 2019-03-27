//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

final class InlineFilterCell: UITableViewCell {

    // MARK: - Public properties

    let view: InlineFilterView

    // MARK: - Init

    init(view: InlineFilterView) {
        self.view = view
        super.init(style: .default, reuseIdentifier: nil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        contentView.addSubview(view)
        view.fillInSuperview(insets: UIEdgeInsets(top: 0, leading: 0, bottom: -.smallSpacing, trailing: 0))
    }
}
