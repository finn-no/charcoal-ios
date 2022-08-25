//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

struct FreeTextSuggestionCellViewModel: IconTitleTableViewCellViewModel {
    var title: String
    let icon: UIImage? = UIImage(named: .searchSmall)
    let iconTintColor: UIColor? = nil
    let hasChevron = false
    let externalIcon: UIImage? = nil
    let subtitle: String? = nil
    let detailText: String? = nil
}
