//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

struct CCListFilterCellViewModel {
    let title: String
    let detail: String?
    let accessoryType: UITableViewCell.AccessoryType
    let icon: UIImage?
}

// MARK: - Kind

extension CCListFilterCellViewModel {
    static func regular(from filter: Filter, isSelected: Bool, hasSelectedSubfilters: Bool) -> CCListFilterCellViewModel {
        let iconAsset: ImageAsset = isSelected ? .checkboxOn : hasSelectedSubfilters ? .checkboxPartial : .checkboxOff

        return CCListFilterCellViewModel(
            title: filter.title,
            detail: String(filter.numberOfResults),
            accessoryType: filter.isLeafFilter ? .none : .disclosureIndicator,
            icon: UIImage(named: iconAsset)
        )
    }

    static func selectAll(from filter: Filter, isSelected: Bool) -> CCListFilterCellViewModel {
        let iconAsset: ImageAsset = isSelected ? .checkboxOn : .checkboxOff

        return CCListFilterCellViewModel(
            title: "all_items_title".localized(),
            detail: String(filter.numberOfResults),
            accessoryType: .none,
            icon: UIImage(named: iconAsset)
        )
    }

    static func map(from filter: Filter) -> CCListFilterCellViewModel {
        return CCListFilterCellViewModel(
            title: filter.title,
            detail: nil,
            accessoryType: .disclosureIndicator,
            icon: UIImage(named: .mapFilterIcon)
        )
    }
}
