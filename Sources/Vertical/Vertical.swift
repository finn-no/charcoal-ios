//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public protocol Vertical: ListItem {
    var title: String { get }
    var isCurrent: Bool { get }
}

extension Vertical {
    public var results: Int { return 0 }
    public var value: String { return "" }
    public var detail: String? { return nil }
    public var showsDisclosureIndicator: Bool { return false }
}
