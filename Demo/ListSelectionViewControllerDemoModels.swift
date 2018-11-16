//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import Foundation

struct DemoListSelectionFilterInfo: ListSelectionFilterInfoType {
    var values: [FilterValueType] {
        return DemoListSelectionFilterInfo.listItems
    }

    var isMultiSelect: Bool {
        return true
    }

    var title: String {
        return "Topp kategori"
    }

    static let listItems: [FilterValueType] = {
        return [
            DemoListItem(title: "Antikviteter og kunst", detail: "64 769", showsDisclosureIndicator: true),
            DemoListItem(title: "Dyr og utstyr", detail: "21 684", showsDisclosureIndicator: true),
            DemoListItem(title: "Elektronikk og hvitevarer", detail: "94 895", showsDisclosureIndicator: true),
            DemoListItem(title: "Foreldre og barn", detail: "64 769", showsDisclosureIndicator: true),
            DemoListItem(title: "Fritid, hobby og underholdning", detail: "4 769", showsDisclosureIndicator: true),
            DemoListItem(title: "Hage, oppussing og hus", detail: "6 769", showsDisclosureIndicator: true),
            DemoListItem(title: "Klær, kosmetikk og accessoirer", detail: "4 712", showsDisclosureIndicator: true),
            DemoListItem(title: "Møbler og interiør", detail: "64 769", showsDisclosureIndicator: true),
            DemoListItem(title: "Næringsvirksomhet", detail: "64 769", showsDisclosureIndicator: true),
            DemoListItem(title: "Sport og fritidsliv", detail: "64 769", showsDisclosureIndicator: true),
            DemoListItem(title: "Utstyr til bil, bår og MC", detail: "64 769", showsDisclosureIndicator: false),
        ]
    }()
}

struct DemoListItem: FilterValueType {
    var title: String
    var detail: String?
    var showsDisclosureIndicator: Bool
    let value: String = ""

    var parentFilterInfo: FilterInfoType? {
        return nil
    }

    var lookupKey: FilterValueUniqueKey {
        return FilterValueUniqueKey(parameterName: "param", value: value)
    }
}
