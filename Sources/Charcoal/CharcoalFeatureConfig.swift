//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FeatureInfo {
    var isEnabled: Bool { get }
    var text: String? { get }
    func didShow()
}

public enum CharcoalFeature {
    case bottomButtonCallout
    case regionReformCallout
}

public protocol CharcoalFeatureConfig {
    func featureConfig(_ feature: CharcoalFeature) -> FeatureInfo?
}
