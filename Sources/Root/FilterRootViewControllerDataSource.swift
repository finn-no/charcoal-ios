//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public protocol FilterInfo {
    var name: String { get }
    var selectedValues: [String] { get }
}

public protocol MultiLevelFilterInfo: FilterInfo, ListItem {
    var level: Int { get }
    var filters: [MultiLevelFilterInfo] { get set }
}

extension MultiLevelFilterInfo {
    public var title: String? { return name }
    public var detail: String? { return nil }
    public var showsDisclosureIndicator: Bool { return numberOfFilters > 0 }
}

extension MultiLevelFilterInfo {
    var numberOfFilters: Int {
        return filters.count
    }
}

public protocol FilterRootViewControllerDataSource: AnyObject {
    var currentSearchQuery: String? { get }
    var searchQueryPlaceholder: String { get }
    var numberOfFilters: Int { get }
    var numberOfContextFilters: Int { get }
    var doneButtonTitle: String { get }

    func filter(at index: Int) -> FilterInfo?
    func contextFilter(at index: Int) -> FilterInfo?
    func multilevelFilter(atIndex index: Int, forFilterAtIndex filterIndex: Int) -> MultiLevelFilterInfo?
}
