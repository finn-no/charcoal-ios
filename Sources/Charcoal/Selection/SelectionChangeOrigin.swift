//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public enum SelectionChangeOrigin {
    case bottomButton
    case freeTextInput
    case freeTextSuggestion(index: Int)
    case inlineFilter
    case navigation
    case removeFilterButton
    case resetAllButton
    case externalSearchFilterTag
}
