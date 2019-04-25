//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public enum SelectionChangeOrigin {
    case bottomButton
    case freeTextInput
    case inlineFilter
    case navigation
    case removeFilterButton
    case resetAllButton
    case suggestion(index: Int)
}
