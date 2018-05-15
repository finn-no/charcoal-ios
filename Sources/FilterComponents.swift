//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public enum FilterComponentType {
    case freeSearch
    case preference
    case multiLevel
}

public protocol FilterComponent {
    var type: FilterComponentType { get }
    var filterInfo: FilterInfo { get }
}

public struct FreeSearchFilterComponent: FilterComponent {
    public typealias Info = FreeSearchFilterInfo

    public let type: FilterComponentType = .freeSearch
    public let filterInfo: FilterInfo

    public init(filterInfo: Info) {
        self.filterInfo = filterInfo
    }
}

public struct PreferenceFilterComponent: FilterComponent {
    public typealias Info = PreferenceFilterInfo

    public let type: FilterComponentType = .preference
    public let filterInfo: FilterInfo

    public init(filterInfo: Info) {
        self.filterInfo = filterInfo
    }
}

public struct MultiLevelFilterComponent: FilterComponent {
    public typealias Info = MultiLevelFilterInfo

    public let type: FilterComponentType = .multiLevel
    public let filterInfo: FilterInfo

    public init(filterInfo: Info) {
        self.filterInfo = filterInfo
    }
}
