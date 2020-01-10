//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import Foundation

public enum FINNFeature {
    case christmasFilter
}

public protocol FeatureConfig: CharcoalFeatureConfig {
    func featureConfig(_ feature: FINNFeature) -> FeatureInfo?
}
