//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

extension UICollectionView {
    func register<T: UICollectionViewCell>(_: T.Type) where T: Identifiable {
        register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T where T: Identifiable {
        return dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}
