//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

enum SimpleDemo: String {
    case bottomsheet
    
    var title: String {
        return rawValue.capitalizingFirstLetter
    }
    
    static var all: [SimpleDemo] {
        return [
            .bottomsheet
        ]
    }
}
