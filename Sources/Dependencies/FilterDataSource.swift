//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterDataSource {
    var filterComponents: [FilterComponent] { get }

    func selectionValuesForFilterComponent(at index: Int) -> [String]
}
