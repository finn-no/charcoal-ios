//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import Foundation

class DemoListSelectionFilterInfo: ListSelectionFilterInfoType {
    var values: [FilterValueType] {
        return DemoListSelectionFilterInfo.listItems
    }

    var isMultiSelect: Bool {
        return true
    }

    var isMapFilter: Bool {
        return false
    }

    var title: String {
        return "Topp kategori"
    }

    static let listItems: [DemoListItem] = {
        return [
            DemoListItem(title: "Antikviteter og kunst", results: 64769, isSelected: false),
            DemoListItem(title: "Dyr og utstyr", results: 21684, isSelected: false),
            DemoListItem(title: "Elektronikk og hvitevarer", results: 94895, isSelected: true),
            DemoListItem(title: "Foreldre og barn", results: 64769, isSelected: false),
            DemoListItem(title: "Fritid, hobby og underholdning", results: 4769, isSelected: false),
            DemoListItem(title: "Hage, oppussing og hus", results: 6769, isSelected: false),
            DemoListItem(title: "Klær, kosmetikk og accessoirer", results: 4712, isSelected: false),
            DemoListItem(title: "Møbler og interiør", results: 64769, isSelected: false),
            DemoListItem(title: "Næringsvirksomhet", results: 64769, isSelected: false),
            DemoListItem(title: "Sport og fritidsliv", results: 64769, isSelected: false),
            DemoListItem(title: "Utstyr til bil, bår og MC", results: 64769, isSelected: false),
        ]
    }()
}

class DemoListItem: FilterValueType, NumberOfHitsCompatible {
    var title: String = ""
    var results: Int = 0
    var value: String {
        return title
    }

    var isSelected: Bool = false

    var parentFilterInfo: FilterInfoType? {
        return nil
    }

    var lookupKey: FilterValueUniqueKey {
        return FilterValueUniqueKey(parameterName: "param", value: value)
    }

    init(title: String, results: Int, isSelected: Bool) {
        self.title = title
        self.results = results
        self.isSelected = isSelected
    }
}

class DemoListFilterSelectionDataSource: FilterSelectionDataSource {
    func setValueAndClearValueForChildren(_ value: String?, for filterInfo: MultiLevelListSelectionFilterInfoType) {
    }

    var filterValues: [DemoListItem] = DemoListSelectionFilterInfo.listItems

    func clearValueAndValueForChildren(for filterInfo: MultiLevelListSelectionFilterInfoType) {
    }

    func clearSelection(at selectionValueIndex: Int, in selectionInfo: FilterSelectionInfo) {
        let sel = selectionInfo as! FilterSelectionDataInfo
        filterValues.first(where: { $0.value == sel.value })?.isSelected = false
    }

    func stepperValue(for filterInfo: StepperFilterInfoType) -> Int? {
        return nil
    }

    func selectionState(_ filterInfo: MultiLevelListSelectionFilterInfoType) -> MultiLevelListItemSelectionState {
        return .none
    }

    func value(for filterInfo: FilterInfoType) -> [String]? {
        return filterValues.compactMap({ $0.isSelected ? $0.value : nil })
    }

    func valueAndSubLevelValues(for filterInfo: FilterInfoType) -> [FilterSelectionInfo] {
        return []
    }

    func setValue(_ filterSelectionValue: [String]?, for filterInfo: FilterInfoType) {
        guard let val = filterSelectionValue?.first else {
            return
        }
        filterValues.first(where: { $0.value == val })?.isSelected = true
    }

    func addValue(_ value: String, for filterInfo: FilterInfoType) {
        filterValues.first(where: { $0.value == value })?.isSelected = true
    }

    func clearAll(for filterInfo: FilterInfoType) {
        filterValues.forEach({ $0.isSelected = false })
    }

    func clearValue(_ value: String, for filterInfo: FilterInfoType) {
        filterValues.first(where: { $0.value == value })?.isSelected = false
    }

    func rangeValue(for filterInfo: RangeFilterInfoType) -> RangeValue? {
        return nil
    }

    func setValue(_ range: RangeValue, for filterInfo: FilterInfoType) {
    }

    func setValue(latitude: Double, longitude: Double, radius: Int, locationName: String?, for filterInfo: FilterInfoType) {
    }

    func setValue(geoFilterValue: GeoFilterValue, for filterInfo: FilterInfoType) {
    }

    func geoValue(for filterInfo: FilterInfoType) -> GeoFilterValue? {
        return nil
    }
}

class DemoListDataSource: FilterDataSource {
    var searchQuery: SearchQueryFilterInfoType?

    var verticals: [Vertical] = []

    var preferences: [PreferenceFilterInfoType] = []

    var filters: [FilterInfoType] = []

    var numberOfHits: Int = 0

    var filterTitle: String = "Demo"

    var filterValuesForHits: [FilterValueType] = DemoListSelectionFilterInfo.listItems

    func numberOfHits(for filterValue: FilterValueType) -> Int {
        return (filterValuesForHits.first(where: { $0.title == filterValue.title }) as? NumberOfHitsCompatible)?.results ?? 0
    }
}
