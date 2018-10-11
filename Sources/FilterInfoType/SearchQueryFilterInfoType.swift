//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public protocol SearchQueryFilterInfoType: FilterInfoType {
    var value: String? { get }
    var placeholderText: String { get }
}
