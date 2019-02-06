//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol CCSelectionTitlesBuilder {
    func build(_ selectedNodes: [CCFilterNode]) -> [String]
}
