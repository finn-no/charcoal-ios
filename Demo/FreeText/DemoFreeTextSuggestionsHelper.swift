//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit

class DemoFreeTextSuggestionsDataSource: FreeTextSuggestionsDataSource {
    func freeTextViewController(_ freeTextViewController: FreeTextViewController, didRequestSuggestionsFor searchTerm: String, completion: @escaping ((String, [String]) -> Void)) {
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1) {
            completion(searchTerm, [searchTerm + " 1", searchTerm + " 2", searchTerm + " 3", searchTerm + " 4"])
        }
    }
}
