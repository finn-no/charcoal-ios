//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

extension UITableView {
    func register<T: UITableViewCell>(_: T.Type) where T: Identifiable {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T where T: Identifiable {
        return dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}
