//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit

class DemoFreeTextSuggestionsHelper: FreeTextSuggestionsHelper {
    func suggestions(for text: String, completion: @escaping ((FreeTextSuggestionsHelper.SuggestionResult) -> Void)) {
        let result = SuggestionResult(text: text, suggestions: [text + " 1", text + " 2", text + " 3", text + " 4"])
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1) {
            completion(result)
        }
    }
}
