//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

extension UITableViewCell {
    func layoutAccessoryView(size: CGFloat = 14) {
        guard let accessoryView = accessoryView else {
            return
        }

        let xPosition = bounds.width - size - .smallSpacing * 3

        accessoryView.frame = CGRect(x: xPosition, y: (bounds.height - size) / 2, width: size, height: size)
        contentView.frame.size.width = xPosition - .mediumSpacing
    }
}
