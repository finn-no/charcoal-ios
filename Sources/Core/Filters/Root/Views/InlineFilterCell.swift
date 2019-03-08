//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

final class InlineFilterCell: UITableViewCell {

    // MARK: - Setup

    func configure(with view: InlineFilterView) {
        if view.superview == nil {
            contentView.addSubview(view)
            view.fillInSuperview(insets: UIEdgeInsets(top: 0, leading: 0, bottom: -.smallSpacing, trailing: 0))
        }
    }
}
