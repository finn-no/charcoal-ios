//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

struct ListFilterCellViewModel: SelectableTableViewCellViewModel {
    enum AccessoryStyle {
        case none
        case chevron
        case external
    }

    enum CheckboxStyle {
        case deselected
        case selectedFilled
        case selectedBordered
    }

    let title: String
    let subtitle: String?
    let detailText: String?
    let accessoryStyle: AccessoryStyle
    let checkboxStyle: CheckboxStyle

    var hasChevron: Bool {
        return accessoryStyle != .none
    }

    var isSelected: Bool {
        return checkboxStyle == .selectedFilled
    }
}

// MARK: - Factory

extension ListFilterCellViewModel {
    static func selectAll(from filter: Filter, isSelected: Bool) -> ListFilterCellViewModel {
        let checkboxStyle: CheckboxStyle = isSelected ? .selectedFilled : .deselected

        return ListFilterCellViewModel(
            title: "all_items_title".localized(),
            subtitle: nil,
            detailText: String(filter.numberOfResults),
            accessoryStyle: .none,
            checkboxStyle: checkboxStyle
        )
    }

    static func regular(from filter: Filter, isSelected: Bool) -> ListFilterCellViewModel {
        let checkboxStyle: CheckboxStyle

        switch isSelected {
        case true:
            checkboxStyle = filter.subfilters.isEmpty ? .selectedFilled : .selectedBordered
        case false:
            checkboxStyle = .deselected
        }

        return ListFilterCellViewModel(
            title: filter.title,
            subtitle: nil,
            detailText: String(filter.numberOfResults),
            accessoryStyle: filter.subfilters.isEmpty ? .none : .chevron,
            checkboxStyle: checkboxStyle
        )
    }

    static func external(from filter: Filter) -> ListFilterCellViewModel {
        return ListFilterCellViewModel(
            title: filter.title,
            subtitle: "opens_in_browser".localized(),
            detailText: String(filter.numberOfResults),
            accessoryStyle: .external,
            checkboxStyle: .deselected
        )
    }
}
