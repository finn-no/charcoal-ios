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

extension CCListFilterCellViewModel {
    func makeMapFilterViewModel(with title: String) -> CClistFilterCellViewModel {
        return CCListFilterCellViewModel(
            title: title,
            detail: nil,
            accessoryType: .disclosureIndicator,
            icon: UIImage(named: .mapFilterIcon)
        )
    }

    func makeFilterViewModel(for node: CCFilterNode, isSelected: Bool, hasSelectedChildren: Bool) -> CCListFilterCellViewModel {
        let iconAsset: ImageAsset = isSelected ? .checkboxOn : hasSelectedChildren ? .checkboxPartial : .checkboxOff

        return CCListFilterCellViewModel(
            title: node.title,
            detail: String(node.numberOfResults),
            accessoryType: node.isLeafNode ? .none : .disclosureIndicator,
            icon: UIImage(named: iconAsset)
        )
    }

    func makeSeeAllViewModel() -> CClistFilterCellViewModel {
        return CCListFilterCellViewModel(
            title: node.title,
            detail: String(node.numberOfResults),
            accessoryType: node.isLeafNode ? .none : .disclosureIndicator,
            icon: UIImage(named: iconAsset)
        )

        selectAllNode = CCFilterNode(
            title: "all_items_title".localized(),
            name: "",
            numberOfResults: filterNode.numberOfResults
        )
    }
}
