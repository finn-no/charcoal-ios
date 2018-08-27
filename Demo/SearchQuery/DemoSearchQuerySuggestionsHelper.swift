//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit

class DemoSearchQuerySuggestionsDataSource: SearchQuerySuggestionsDataSource {
    func searchQueryViewController(_: SearchQueryViewController, didRequestSuggestionsFor searchQuery: String, completion: @escaping ((String, [String]) -> Void)) {
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1) {
            completion(searchQuery, [searchQuery + " 1", searchQuery + " 2", searchQuery + " 3", searchQuery + " 4"])
        }
    }
}
