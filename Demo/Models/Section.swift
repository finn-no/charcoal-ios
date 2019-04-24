//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class Section {
    // MARK: - Internal properties

    let title: String
    let data: [Row]

    // MARK: - Init

    init(title: String, data: [Row]) {
        self.title = title
        self.data = data
    }
}
