//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

extension UITableView {
    func removeLastCellSeparator() {
        tableFooterView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: 1)))
    }
}
