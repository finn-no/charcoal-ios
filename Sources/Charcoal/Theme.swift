//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import UIKit

public class Theme {
    /// The background used for charcoal will be different in dark mode than the standard FinniversKit as charcoal
    /// components are presented on top of other elements, then in order to achieve more contrast and a sense of levels
    /// we need to override the value for the main background color for dark mode.
    public class var mainBackground: UIColor {
        return .bgBottomSheet
    }
}
