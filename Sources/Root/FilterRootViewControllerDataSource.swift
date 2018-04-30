//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public protocol FilterInfo {
    var name: String { get }
    var selectedValues: [String] { get }
}

public protocol FilterRootViewControllerDataSource: AnyObject {
    var currentSearchQuery: String? { get }
    var searchQueryPlaceholder: String { get }
    var numberOfFilters: Int { get }
    var numberOfContextFilters: Int { get }
    var hasPreferences: Bool { get }
    var doneButtonTitle: String { get }
    var preferencesView: HorizontalScrollButtonGroupView? { get }

    func filter(at index: Int) -> FilterInfo?
    func contextFilter(at index: Int) -> FilterInfo?
}
