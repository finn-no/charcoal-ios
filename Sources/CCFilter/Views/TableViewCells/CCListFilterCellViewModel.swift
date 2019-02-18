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
    static func regular(from node: CCFilterNode, isSelected: Bool, hasSelectedChildren: Bool) -> CCListFilterCellViewModel {
        let iconAsset: ImageAsset = isSelected ? .checkboxOn : hasSelectedChildren ? .checkboxPartial : .checkboxOff

        return CCListFilterCellViewModel(
            title: node.title,
            detail: String(node.numberOfResults),
            accessoryType: node.isLeafNode ? .none : .disclosureIndicator,
            icon: UIImage(named: iconAsset)
        )
    }

    static func selectAll(from node: CCFilterNode, isSelected: Bool) -> CCListFilterCellViewModel {
        let iconAsset: ImageAsset = isSelected ? .checkboxOn : .checkboxOff

        return CCListFilterCellViewModel(
            title: "all_items_title".localized(),
            detail: String(node.numberOfResults),
            accessoryType: .none,
            icon: UIImage(named: iconAsset)
        )
    }

    static func map(from node: CCFilterNode) -> CCListFilterCellViewModel {
        return CCListFilterCellViewModel(
            title: node.title,
            detail: nil,
            accessoryType: .disclosureIndicator,
            icon: UIImage(named: .mapFilterIcon)
        )
    }
}
