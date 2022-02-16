//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public protocol Vertical {
    var title: String { get }
    var isCurrent: Bool { get }
    var isExternal: Bool { get }
    var calloutText: String? { get }
}
