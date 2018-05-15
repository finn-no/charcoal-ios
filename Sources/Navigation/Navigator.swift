//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol Navigator {
    associatedtype Destination

    func start()
    func navigate(to destination: Destination)
}
