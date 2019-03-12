//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol EventLogging {
    func log(event: Event)
}

// MARK: - Events

public struct Event {
    public enum Kind {
        case filterApplied
        case rangeKeyboardOpened
        case rangeSliderUsed
        case bottomButtonClicked
        case backButtonClicked
        case rootSelectionTagRemoved
    }

    public let filter: Filter
    public let kind: Kind
}
