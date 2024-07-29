//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit
import Warp

extension UITableViewCell {
    func layoutAccessoryView(size: CGFloat = 14) {
        guard let accessoryView = accessoryView else {
            return
        }

        let xPosition = bounds.width - size - Warp.Spacing.spacing50 * 3

        accessoryView.frame = CGRect(x: xPosition, y: (bounds.height - size) / 2, width: size, height: size)
        contentView.frame.size.width = xPosition - Warp.Spacing.spacing100
    }
}
