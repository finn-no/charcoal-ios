//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol EventLogging {
    func log(event: Event)
}

// MARK: - Events

public enum Event {
    case selectionChangedByBottomButton
    case selectionChangedByNavigation
    case selectionTagRemovedFromRoot(filter: Filter)

    case rangeKeyboardOpened
    case rangeSliderUsed
}
