//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

final class FeedbackGenerator {
    enum Feedback {
        case selection
        case error
        case collision
    }

    static func generate(_ feedback: Feedback) {
        if #available(iOS 10.0, *) {
            switch feedback {
            case .selection:
                let generator = UISelectionFeedbackGenerator()
                generator.selectionChanged()
            case .error:
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            case .collision:
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
        }
    }
}
