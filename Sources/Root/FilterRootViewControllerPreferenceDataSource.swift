//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public protocol PreferenceValue: ListItem {
    var name: String { get }
    var isSelected: Bool { get }
}

// MARK: - ListItem default implementation

extension PreferenceValue {
    public var title: String? { return name }
    public var detail: String? { return nil }
    public var showsDisclosureIndicator: Bool { return false }
}

public protocol PreferenceInfo {
    var name: String { get }
    var numberOfValues: Int { get }
    func value(at index: Int) -> PreferenceValue?
}

public protocol FilterRootViewControllerPreferenceDataSource: AnyObject {
    var hasPreferences: Bool { get }
    var preferencesDataSource: HorizontalScrollButtonGroupViewDataSource? { get }
    func preference(at index: Int) -> PreferenceInfo?
}
