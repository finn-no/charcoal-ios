//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public protocol PreferenceValue {
    var name: String { get }
    var isSelected: Bool { get }
}

public protocol PreferenceInfo {
    var name: String { get }
    var numberOfValues: Int { get }
    func value(at index: Int) -> PreferenceValue?
}

public protocol FilterRootViewControllerPreferenceDataSource: AnyObject {
    var hasPreferences: Bool { get }
    var preferencesDataSource: PreferenceSelectionViewDataSource? { get }
    func preference(at index: Int) -> PreferenceInfo?
}
