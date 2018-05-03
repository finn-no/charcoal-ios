//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public protocol Identifiable {
    static var reuseIdentifier: String { get }
}

public extension Identifiable {
    public static var reuseIdentifier: String {
        return String(describing: self)
    }
}
