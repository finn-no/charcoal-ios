//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

struct PreferenceValuesSelectionDataSource: ValueSelectionViewControllerDataSource {
    private let preferenceInfo: PreferenceInfo

    init(preferenceInfo: PreferenceInfo) {
        self.preferenceInfo = preferenceInfo
    }

    var count: Int {
        return preferenceInfo.numberOfValues
    }

    func nameForItem(at index: Int) -> String {
        guard let value = preferenceInfo.value(at: index) else {
            return ""
        }
        return value.name
    }
}
