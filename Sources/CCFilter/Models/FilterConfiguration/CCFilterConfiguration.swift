//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol CCFilterConfiguration {
    func viewModel(for rangeNode: CCRangeFilterNode) -> RangeFilterInfo?
}
